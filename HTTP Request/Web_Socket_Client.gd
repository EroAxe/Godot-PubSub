extends Node


""" SIGNALS """

# Emitted when connection to the pubsub is established.  Sends over the channel ID for saying which connection 
#it's coming from
signal pubsub_connected(channel_id)

# Emitted when a reward is redeemed on the connected channel
signal reward_redeemed(redemption, reward, user_input)


""" VARIABLES """

var websocket = WebSocketClient.new()

var peer


var URL = "wss://pubsub-edge.twitch.tv"


var first_time = true

var topics = ["channel-points-channel-v1.%"]


onready var listeners = {
	
	"type": "LISTEN",
	
	"nonce": "",
	
	"data": {
		
		"topics": topics,
		"auth_token" : ""
		
		}
}

var ping = {
	
	"type" : "PING"
	
}


# Called when the node enters the scene tree for the first time.
func _ready():
	
#	websocket.verify_ssl = true
	
	
	websocket.connect("data_received", self, "received_info")
	
	websocket.connect("connection_established", self, "connection_established")
	
	websocket.connect("connection_closed", self, "connection_closed")
	
	
	set_process(false)
	


func replace_id():
	
	for all in topics.size():
		
		topics[all] = topics[all].replace("%", Globals.credentials["channel_id"])
		
	
	listeners["data"]["topics"] = topics
	print("Topics Are: ", topics)
	

# Connects to the specified websocket, Twitch PubSub
func connect_to_websocket():
	
#	Sets the auth token based off the token saved in credentials.
	listeners["data"]["auth_token"] = Globals.cred_manager.read_token(Globals.cred_manager.user)
	
	if Globals.state != "Temp":
	#	Sets the nonce, or "state" essentially a password for the connection.
	#	Is set based off Globals.state since it shouldn't be changing anymore
		listeners["nonce"] = Globals.state
		
	else:
		
		listeners["nonce"] = Globals.create_state()
		
	
	
#	Replaces the % with the supplied Channel ID
	replace_id()
	printraw(listeners)
	
#	Connects the websocket to the URL
	websocket.connect_to_url(URL)
	
	set_process(true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	websocket.poll()
	

func connection_established(protocol):
	
	if first_time:
		
		peer = websocket.get_peer(1)
		
		peer.set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
		
		
		first_time = false
		
		
		send_var(ping, true)
		
		
		yield(websocket, "data_received")
		
		send_var(listeners, false)
		
	

func connection_closed(was_clean):
	
	if !was_clean:
		
		push_error("WS Error: Disconnection from Socket was not Clean")
		
	
	set_process(false)
	


func check_response_type(packet, info):
	
	var message
	
	if info.has("data"):
	#	Sets Infos message to a json for easier accessing later.  Since Twitch sends it in a dumb way
		info["data"]["message"] = parse_json(info["data"]["message"])
		
		message = info["data"]["message"]
		
	
#	Match for checking the type of the response from Twitch.  Changes how it's handled
	match info["type"]:
	
#		Response from twitch upon receiving ping message.  Don't need to do anything
		"PONG":
			
			print(info["type"])
			pass
			
		
#		Sent by twitch when you need to reconnect to the server.  Generally when it's clearing websockets
		"RECONNECT":
			
#			Outputs the type of info received from Twitch
			print(info["type"])
			
			print("Received Reconnect Message")
#			Reconnection Logic, needs exponential backoff on reconnecting.
			websocket.disconnect_from_host()

			OS.delay_msec(5000)

			if websocket.connect_to_url(URL) != OK:

				push_error("WS Error: Unable to Reconnect To Twitch")


			pass
			
		
#		Sent by twitch upon receiving a listener command to the websocket
		"RESPONSE":
			
#			Outputs the type of info received from Twitch
			print(info["type"])
			
			if !info.has("nonce") or info["nonce"] != Globals.state:
				
#				Pushes out a WS_R error since it's an from Websocket Response
				push_error("WS_R Error: Supplied Nonce did not Match or No Nonce Supplied")
				
				
				printraw(info)
				
				printraw("\n")
				
				printraw(Globals.state)
				
				return
				
			
			if !info["error"].empty():
				
#				Pushes out a WS_R Error with the supplied error from Twitch
				push_error("WS_R Error from Twitch: " + info["error"])
				
#				Disconnects the websocket to allow reconnecting after the error is resolved.
				websocket.disconnect_from_host(1002, "Need to Resolve Error")
				
				return
				
			
			emit_signal("pubsub_connected")
			
		
		"MESSAGE":
			
#			Outputs the type of info received from Twitch
			print(info["type"])
			
			var rec_topic = info["data"]["topic"]
			
			var rec_message = info["data"]["message"]
			
#			List of possible scopes, specifically the portion of them to check for in If statements
#				automod, moderation, moderator, subscribe, points, bits
			
#			Checks if the received message is about a channel redeem
			if "points" in rec_topic:
				
				var redemption = rec_message["data"]["redemption"]
				
				var reward = rec_message["data"]["redemption"]["reward"]
				
#				Sets up the user input variable, and then makes sure that Twitch sent back a user_input
				var user_input 
				
				if rec_message["data"]["redemption"].has("user_input"):
					
					user_input = rec_message["data"]["redemption"]["user_input"]
					
				
#				Emits the reward redeemed signal.  Can be connected wherever, has most relevent information.
				emit_signal("reward_redeemed", redemption, reward, user_input)
				
				pass
				
			
#			Triggered by a bits event from Twitch
			elif "bits" in rec_topic:
				
				pass
				
			
#			Triggered by a subscription event as the Topic
			elif "subscribe" in rec_topic:
				
				pass
				
			
#			Triggered by a Automod action flagging a message, generally
			elif "automod" in rec_topic:
				
				pass
				
			
#			Triggered by a moderator 
			elif "moderator" in rec_topic:
				
				pass
				
			
	


""" HELPER FUNCTIONS FOR SENDING INFO """

# Sends a variable, can be a straight variable with any value,
# Has is_ping for use with the timer node that sends pings on a set interval.
func send_var(variable, is_ping):
	
	if is_ping:
		
		peer.put_packet(JSON.print(ping).to_utf8())
		
	else:
		
		peer.put_packet(JSON.print(variable).to_utf8())
		printraw(JSON.print(variable))
		
	

# Sends a packet, should be encoded in a PoolByteArray, need to add
func send_packet(packet):
	
	websocket.get_peer(1).put_packet(packet)
	

""" SIGNAL CONNECTED FUNCTIONS """

# Called when the data received signal goes off.  Has no arguments because packets need to be pulled
func received_info():
	
#	Grab the current packet from the peer, AKA the Twitch server, should be get_peer(1)
	var packet = websocket.get_peer(1).get_packet()
	
	
#	Gets the info from that packet parsed into a json
	var info = parse_json(packet.get_string_from_utf8())
	
	
	check_response_type(packet, info)
	
	
#	print(info)
#
#	var data
#	var input
#
#	var type
#
#	if info.has("data"):
#
#		var temp = info["data"]["message"]
#
##		match info["data"]
#
#
#		type = temp["type"]
#
#		data = temp["data"]
#
#		input = data["redemption"]["user_input"]
#
#
#	print(info["type"])
#
#
#	if info.has("error"):
#
#		push_error("Web Socket Client Error: " + info["error"])
#		printraw(data)
#
#		return
#
#
#	if info["type"] == "RESPONSE":
#
#		printraw("Data Received From Twitch \n")
#		printraw(data)
#
#
#	if info["type"] == "MESSAGE":
#
#		printraw("Message Received from Twitch \n")
#		print(data["redemption"]["user"]["display_name"])
#		print(input)
#
#
	pass
	



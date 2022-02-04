extends GraphNode

# Response Signals needs to be added First in the Script to ensure they are read
""" RESPONSE SIGNALS """

# Takes an array with Redemption, Reward and User_Input
signal send_reward_redeemed(args)

# Takes an array with user_name, bits, total_bits and is_anonymous
signal send_bits_event(args)

# Takes an array with display_name and badge
signal send_bits_badge_event(args)

# Takes an array with context, subscriber, tier, months, total_months, streak and multi_month
signal send_subscribe_event(args)


"""  AUTH SIGNALS """

signal got_token()

signal got_channelid()

signal token_check()

signal got_redeems()


""" WEB CONNECTORS """

var http = HTTPRequest.new()

var server = TCP_Server.new()

var websocket = WebSocketClient.new()


""" DATA/LISTENERS """

var ping = {"type" : "PING"}

var topics = []

var scopes = []

var listeners = {
	"type" : "LISTEN",
	"nonce" : "",
	"data" : {
		
		"topics" : [],
		"auth_token" : ""
		
	}
}

# The specified users redeems on their channel
var redeems : Dictionary

""" VARIABLES """

# State, used for identifying responding requests
var state 

# Type of HTTP Request, set based off what's needed to make sure it's read right
var request_type

# Change to true when requesting authentication for a new account
var auth_requested = false

var user

var web_url = "wss://pubsub-edge.twitch.tv"

export var max_retries = 3

var bad_token = false



# Called when the node enters the scene tree for the first time.
func _ready():
	
#	Makes a nonce, used for identifying requests meant for this node and the right request in General
	state = Globals.make_nonce(8)
	
	user = Globals.default_user
	
	
	listeners["nonce"] = state
	
	
#	Adds the HTTP to the tree since apparently it needs to be added
	add_child(http, true)
	
#	Connects the request completed to check HTTP
	http.connect("request_completed", self, "check_http")

	
#	Functions to consolidate signal connections
	websocket_signals()
	

# Updates the user if the inputted user changes.  
func update_user(user):
	
	self.user = user
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
#if websocket.get_peer(1).is_connected_to_host():
	
	websocket.poll()
	
	
	if auth_requested == true:
		
		if !server.is_listening():
			
			server.listen(80)
			
		
		check_server()
		
	

# Connected to Get Authentication Button.  Gets authentication off a first time user.  Assuming
func get_authentication():
	
	open_auth_page()
	
	yield(self, "got_token")
	
	
	request_channelid(user)
	
	yield(self, "got_channelid")
	
	
	setup_topics(topics, user)
	

func test_authentication():
	
#	Requests a quick check of the OAuth Token
	request_token_check(user)
	
	yield(self, "token_check")
	
	
	request_redeems(user)
	
	yield(self, "got_redeems")
	
	
#	Sets up the topics.
	setup_topics(topics, user)
	
#	Connects to the websocket
	connect_websocket()
	

""" SIGNAL CONNECTIONS """

# Connects all needed Server and Websocket signals.
func websocket_signals():
	
	websocket.connect("connection_established", self, "websocket_connected")
	
	websocket.connect("data_received", self, "check_websocket")
	
	websocket.connect("connection_closed", self, "close_websocket")
	

func close_websocket(was_clean):
	
	if !was_clean:
		
		push_error("Twitch WS Error: Websocket Lost Connection Badly.  Unsure as to why.")
		
	

""" REQUESTERS """

# Opens the authentication page with the selected scopes to request an oauth code from Twitch
func open_auth_page():
	
	auth_requested = true
	server.listen(80)
	
	
	var full_scope : String
	
	var first_scope = true
	
	for all in scopes.size():
		
		if !first_scope:
			
			full_scope += " " + scopes[all]
			
		else:
			
			full_scope += scopes[all]
			
			first_scope = false
			
		
	
	OS.shell_open("https://id.twitch.tv/oauth2/authorize" + \
				"?client_id=" + Globals.client_id + "&redirect_uri=http://localhost" + \
				"&response_type=code&scope=" + full_scope + "&state=" + state)
	

# Requests a oauth token from Twitch using an authentication code after authorization
func request_token(code, user):
	
	var err = http.request("https://id.twitch.tv/oauth2/token?client_id=" + Globals.client_id +\
				"&client_secret=" + Globals.client_secret + "&code=" + code + \
				"&grant_type=authorization_code&redirect_uri=http://localhost", [],
				false, HTTPClient.METHOD_POST)

#https://id.twitch.tv/oauth2/token
#    ?client_id=uo6dggojyb8d6soh92zknwmi5ej1q2
#    &client_secret=nyo51xcdrerl8z9m56w9w6wg
#    &code=394a8bc98028f39660e53025de824134fb46313
#    &grant_type=authorization_code
#    &redirect_uri=http://localhost

	if err == OK:
		
		request_type = "token"
		
	else:
		
		push_error("Twitch HTTP Error: " + str(err) + "was received while requesting token" +\
		"please save and retry")
		
		return err
		
	

# Requests the channel ID of the specified user for use in the topics of websockets etc.
func request_channelid(user):
	
	var err = http.request("https://api.twitch.tv/helix/users?login=" + user, 
				["Authorization: Bearer " + \
				
#				Calls the decrypt data function
				Globals.cred_manager.read_token(user), "Client-Id: " + Globals.client_id],
				true, HTTPClient.METHOD_GET)
				
			
	
	if err == OK:
		
		request_type = "channel_id"
		
	else:
		
		push_error("Twitch HTTP Error: " + str(err) + "was received while requesting channel_id," +\
		"please save and Retry")
		
		return err
		
	

# Requests a token check from Twitch.  If a response is received then it was a valid token
func request_token_check(user):
	
	request_type = "token_check"
	
	var token = Globals.cred_manager.read_token(user)
	
	if !token:
		
		push_error("Twitch Token Check Error: No saved Token was found.  Please Get Authentication")
		
		return
		
	
	
	var err = http.request("https://id.twitch.tv/oauth2/validate",
							["Authorization: Bearer " + token],
							HTTPClient.METHOD_GET)
	
	if err != OK:
		
		push_error("Twitch Token Check Error: " + str(err) + " was received from Twitch")
		
	

# Requests all the channel point redeems of a specified channel
func request_redeems(user):
	
	request_type = "get_redeems"
	
	var token = Globals.cred_manager.read_token(user)
	
	var id = Globals.credentials[user]["channel_id"]
	
	
	var err = http.request("https://api.twitch.tv/helix/channel_points/custom_rewards?broadcaster_id=" + \
							id, ["Client-Id: " + Globals.client_id, "Authorization: Bearer " + token])
	
	if err != OK:
		
		push_error("Twitch Redeem Request Error: " + str(err) + " was received")
		
	

# Connects to the specified URL for the websocket
func connect_websocket():
	
	if websocket.get_peer(1).is_connected_to_host():
		
		websocket.disconnect_from_host()
		
	
	websocket.connect_to_url(web_url)
	

""" HELPER FUNCTIONS """

# Sends a specific variable to the specified peer.  Or if it was a ping call it sends a ping
func send_var(peer, variable, is_ping):
	
	if is_ping:
		
		websocket.get_peer(1).put_packet(JSON.print(ping).to_utf8())
		
	else:
		
		peer.put_packet(JSON.print(variable).to_utf8())
		
		printraw(JSON.print(variable))
		
	

# Sets up the topics by replacing the % with channel ID to make sure it's ready to send
func setup_topics(topics, user):
	
	if Globals.credentials[user].has("channel_id"):
		
#		Formats all the topics to replace % with the Channel ID
		for all in topics.size():
			
			topics[all] = topics[all].format([Globals.credentials[user]["channel_id"]], "%")
			
		
#		Saves the topics selected for the specified user
		Globals.credentials[user]["topics"] = topics
		
		
		listeners["data"]["topics"] = topics
		
		return OK
		
	else:
		
#		Returns false to say that there was no channel ID saved.  
#		So a channel ID can be requested where it is needed
		return false
		
	

""" SIGNAL FUNCTIONS """


func bad_token_check():
	
	bad_token = true
	
	emit_signal("token_check")
	

# Triggered when the websocket receives a connection
func websocket_connected(proto):
	
	if Globals.credentials.has(user) and Globals.credentials[user].has("token"):
		
		listeners["data"]["auth_token"] = Globals.cred_manager.read_token(user)
		
		websocket.refuse_new_connections = true
		
		
		var peer = websocket.get_peer(1)
		
		peer.set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
		
	#	Sends out a PING to ensure Twitch doesn't close the connection
		send_var(peer, ping, true)
		
	#	Sends out the listeners as set on the Deck/Node
		send_var(peer, listeners, false)
		
	else:
		
		push_error("Twitch WS_C Error: No OAuth Token Saved.  Please Get Authentication and Retry")
		
		return
		
	


""" RESPONSE CHECKERS """

# Checks the TPC server if looking for an authentication code from Twitch
func check_server():
	
	if server.is_connection_available():
		
		var peer = server.take_connection()
		
		var bytes = peer.get_available_bytes()
		
		
		var info = peer.get_utf8_string(bytes)
		
		printraw(info)
		
		if info == "":
			
			push_error("Twitch HTTP Error: No Info received from Twitch.  Please wait and Retry, or reboot")
			
			return
			
		
#		Splits the received info by &state= to get the state itself out. 
		var request_state = info.split("&state=")
		
#		Sets the request state to the actual state after &state=
		request_state = request_state[1]
		
		request_state = request_state.split(" ")[0]
		
		
		if request_state == state:
			
#			Get out the authorization code which is in the format &code=codestringhere 
			
#			Splits the request to get code out of it. And sets code to whatever is after the split
			var code = info.split("?code=")
			
			code = code[1]
			
#			Splits code by & to get rid of State off the end.
			code = code.split("&")[0]
			
			
			server.stop()
			
			auth_requested = false
			
			
			request_token(code, user)
			
		

# Goes off when a request is completed for the HTTPRequest.  Reads it for the needed info
func check_http(result, response_code, headers, body):
	
	var temp_body = body.get_string_from_utf8()
	
	var response = parse_json(temp_body)
	
	if response.has("status"):
		
		push_error("Twitch HTTP Error: Twitch responded with status " + str(response["status"]))
		
		return
		
	
	match request_type:
		
#		Received if request was asking for a token.  Needs to get the token out
		"token":
			
#			Saves and encrypts both the token and refresh token
			Globals.credentials[user]["token"] = Globals.cred_manager.encrypt_data(
											response["access_token"])
			
			Globals.credentials[user]["refresh_token"] = Globals.cred_manager.encrypt_data(
										response["refresh_token"])
			
#			http.close()
			
			emit_signal("got_token")
			
			pass
			
		
#		Received if request was Channel ID, needs to get channel ID out
		"channel_id":
			
			Globals.credentials[user]["channel_id"] = response["data"][0]["id"]
			
			Globals.credentials[user]["display_name"] = response["data"][0]["display_name"]
			
#			http.close()
			
			emit_signal("got_channelid")
			
			pass
			
		
#		Received if the token was checked to make sure it is still valid.  If received it was valid
		"token_check":
			
			if !response.has("error"):
				
				print("Token was good from Twitch")
				
				emit_signal("token_check")
				
			else:
				
				push_error("Twitch T_C Error: Received Error " + response["error"] + " from Twitch. When Checking Token")
				
			
		
		"get_redeems":
			
			if !response.has("error"):
				
				for all in response["data"]:
					
					var rew_title = all["title"]
					
					redeems[rew_title] = all
					
				
				emit_signal("got_redeems")
				
			else:
				
				push_error("Twitch Get Redeems Response Error: " + response.error + " received on Twitch response")
				
		
	
	pass
	

# Goes off when data is received by the websocket.  Then reads it and sends it to be parsed
func check_websocket():
	
#	Received data packet from Twitch
	var packet = websocket.get_peer(1).get_packet()
	
#	Data packet info parsed into a JSON
	var info = parse_json(packet.get_string_from_utf8())
	
	
	var message
	
	if info.has("data"):
		
		info["data"]["message"] = parse_json(info["data"]["message"])
		
		message = info["data"]["message"]
		
	
	
#	Used for checking the type of response received from Twitch outside of Code
	print(info["type"])
	
	match info["type"]:
		
#		Received when Twitch is playing Ping Pong
		"PONG":
			
			print("Twitch is playing Ping Pong")
			
		
#		Received when Twitch wants the Websocket to reconnect to Twitch
		"RECONNECT":
			
			print("Received Reconnect Message")
			
			websocket.disconnect_from_host()
			
			OS.delay_msec(5000)
			
			if websocket.connect_to_url(web_url) != OK:
				
				push_error("Twitch WS_R Error: Unable to Reconnect to Twitch.  Please Try Again" )
				
			
		
#		Received when Twitch is responding to the first listen call.  Will be where most errors are mentioned
		"RESPONSE":
			
			if !info["nonce"] == state:
				
				push_error("Twitch WS_R Error: Received wrong confirmation Code/Nonce on Twitch Response to connection")
				
				return
				
			
			if !info["error"].empty():
				
				push_error("Twitch WS_R Error: Received an error from Twitch.  Error was " + info["error"])
				
				
				websocket.disconnect_from_host(1002, "Need to resolve received error")
				
				return
				
			
			$Ping_Timer.start()
			
		
#		Received when Twitch is sending data on one of the topics being listened to.
		"MESSAGE":
			
			
			var rec_topic = info["data"]["topic"]
			
			var rec_message = info["data"]["message"]
			
#			List of possible scopes, specifically the portion of them to check for in If statements
#				subscribe, points, bits
			
			
#			Checks if points is in the received Topic, and then goes through all the alternative topics
#			checks all of them just for ease even if they're not actually enabled
			if "points" in rec_topic:
				
				var redemption = rec_message["data"]["redemption"]
				
				var reward = rec_message["data"]["redemption"]["reward"]
				
				var user_input = false
				
				
				if reward["is_user_input_required"]:
					
					user_input = redemption["user_input"]
					
				
				emit_signal("send_reward_redeemed", {"redemption" : redemption, 
													"reward" : reward, 
													"input" : user_input})
				
#				var values : Dictionary
#
#				print(rec_message.duplicate())
#
#				for all in rec_message.keys():
#
#					for value in rec_message.values():
#
#						if value is Dictionary:
#
#							for v_all in value.keys():
#
#								pass
#
##								values[]


#						values[all] = value
	
				
			
#			Checks if there were bits events received and parses through
			elif "bits-events" in rec_topic:
				
				pass
				
			
#			Checks if there were bits badge changes received and parses through
			elif "bits-badges" in rec_topic:
				
				pass
				
			
#			Checks if there were subscribe events received and parses through.
			elif "subscribe-events" in rec_topic:
				
				pass
				
			
		
	
	pass
	




extends Node


var websocket = WebSocketClient.new()

var URL = "wss://pubsub-edge.twitch.tv"


var first_time = true

onready var listeners = {
	
	"type": "LISTEN",
	
	"nonce": Globals.make_nonce(10),
	
	"data": {
		
		"topics": ["channel-bits-events-v1.44322889"],
		"auth_token": Globals.token
		
		}
}

var ping = {
	
	"type" : "PING"
	
}


# Called when the node enters the scene tree for the first time.
func _ready():
	
	websocket.verify_ssl = true
	
	
	websocket.connect("data_received", self, "received_info")
	
	websocket.connect("connection_established", self, "connection_established")
	


func connect_to_websocket():
	
	websocket.connect_to_url(URL)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	websocket.poll()
	

func connection_established(protocol):
	
	if first_time:
		
		first_time = false
		
		send_var(listeners, false)
		send_var(ping, true)
		
	

""" HELPER FUNCTIONS FOR SENDING INFO """

# Sends a variable, can be a straight variable with any value
func send_var(variable, is_ping):
	
	if is_ping:
		
		websocket.get_peer(1).put_var(ping)
		
	else:
		
		websocket.get_peer(1).put_var(variable)
		
	

# Sends a packet, should be encoded in a PoolByteArray, need to add
func send_packet(packet):
	
	websocket.get_peer(1).put_packet(packet)
	

""" SIGNAL CONNECTED FUNCTIONS """

# Called when the data received signal goes off.  Has no arguments because packets need to be pulled
func received_info():
	
#	Grab the current packet from the peer, AKA the Twitch server, should be get_peer(1)
	
	var packet = websocket.get_peer(1).get_packet()
	
	var data = parse_json(packet.get_string_from_utf8())
	
	
	print(data["type"])
	
	pass
	



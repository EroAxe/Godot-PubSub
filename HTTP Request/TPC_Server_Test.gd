extends Node


signal get_token()


var server = TCP_Server.new()

#onready var state = Globals.state


var info

var peer


var one_shot = true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	server.listen(80, "*")
	
	set_process(false)
	
	pass
	



func _input(event):
	
	if Input.is_action_just_released("open_auth") and one_shot:
		
		one_shot = false
		
		
		var URI = "https://id.twitch.tv/oauth2/authorize?response_type=code&client_id=" \
				+ Globals.credentials["client_id"] + "&redirect_uri=http://localhost&scope=channel:read:redemptions&state=" \
				+ Globals.create_state()
		
		OS.shell_open(URI)
		
		
		yield(get_tree().create_timer(2), "timeout")
		
		set_process(true)
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if server.is_connection_available():
		
#		An easy access to the peer returned by the server on making a connection
		peer = server.take_connection()
		
#		Saves the total number of bytes that were received
		var bytes = peer.get_available_bytes()
		
		info = peer.get_utf8_string(bytes)
		
		printraw("Info: ", info)
		
#		Grabs the state received
		var received_state = info.split("&")[-1]
		
#		: d12f1935 HTTP/1.1
#		Trims the & prefix in case it doesn't get removed by the split
		received_state = received_state.trim_prefix("&")
		
#		Replaces the state= prefix with nothing to remove it from the string.
		received_state = received_state.replace("state=", "")
		
#		Splits by spaces and grabs thhe second element in the array
		received_state = received_state.split(" ")[0]
		
		print("State received from Twitch: ", received_state)
		
		
		if received_state == Globals.state:
			
			print(peer)
			print("Something")
			
			
#			GET ?code=
			
			var temp_code = info.substr(11,30)
			
			temp_code = temp_code.replace(" ", "")
			
			printraw("Cut Code: ", temp_code)
			
			
			Globals.code = temp_code
			
#			print("Auth Code: ", temp_code)
			
			
			call_deferred("emit_signal", "get_token")
			
#			set_process(false)
			
#		else:
#			
#			print("State was not the Same")
#			
#		print(peer.get_utf8_string(43))
		
#	else:
#
#		print("No connection found")
		
	

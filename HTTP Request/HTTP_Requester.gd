extends HTTPRequest


signal got_token()

signal connect_websocket()


var token

var request_type


# Called when the node enters the scene tree for the first time.
func _ready():
	
#	connect("got_token", $"../Web_Socket_Client", "connect_to_websocket")
	
#	OS.shell_open(OS.get_user_data_dir())
	
#	if Globals.cred_manager.read_token(Globals.cred_manager.user) != "Temp":
#
#		grab_token()
#
	
	pass
	

# URL to get the Code if needed
#	https://id.twitch.tv/oauth2/authorize?response_type=code&client_id= Globals.client_id 
#	&redirect_uri=http://localhost&scope=channel:read:redemptions&state=

# Grabs the token when it's called based off of whats needed.
func grab_token():
	
	request_type = "token"
	
	request("https://id.twitch.tv/oauth2/token?client_id=" + Globals.client_id \
			+ "&client_secret=" + Globals.client_secret + \
			"&code=" + Globals.code + \
			"&grant_type=authorization_code" + \
			"&redirect_uri=http://localhost", 
			[], true, HTTPClient.METHOD_POST)
			
		
	
	pass
	


func get_channel_id(channel_name):
	
	request_type = "channel_id"
	
	
	request("https://api.twitch.tv/helix/users?login=" + channel_name, 
				["Authorization: Bearer " + Globals.cred_manager.read_token(Globals.cred_manager.user), 
				"Client-Id: " + Globals.client_id])
	
#	emit_signal("connect_websocket")
	

func check_token():
	
	request_type = "token_check"
	
	printraw(request("https://id.twitch.tv/oauth2/validate", [
			"Authorization: Bearer " + Globals.cred_manager.read_token(Globals.cred_manager.user)
	]))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func token_grabbed(result, response_code, headers, body):
	
#	printt(result, response_code, headers, body.get_string_from_utf8())
	
	var response = parse_json(body.get_string_from_utf8())
	
	if request_type == "token":
		
		var temp_user = Globals.cred_manager.user
		
		if !Globals.cred_manager.user == "":
			
			Globals.credentials[temp_user]["token"] = Globals.cred_manager.encrypt_data(response["access_token"])
			
			Globals.credentials[temp_user]["refresh_token"] = Globals.cred_manager.encrypt_data(response["refresh_token"])
			
		else:
			
			push_error("Token Grab Error: No Username Entered into the set channel, Please enter a Username "+\
						"then retry the Authentication Button")
			
			return
			
		
		get_channel_id("eroaxee")
		
	elif request_type == "channel_id":
		
#		print(response)
		
		Globals.credentials["channel_id"] = response["data"][0]["id"]
		
		Globals.credentials["display_name"] = response["data"][0]["display_name"]
		
		Globals.save_data()
		
		
		check_token()
		
		emit_signal("connect_websocket")
		
	elif request_type == "token_check":
		
		printraw(response)
		
#	print(response)
	
	pass
	

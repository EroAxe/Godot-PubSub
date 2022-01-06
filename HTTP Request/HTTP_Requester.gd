extends HTTPRequest


signal got_token()

signal connect_websocket()


var token

var request_type


# Called when the node enters the scene tree for the first time.
func _ready():
	
#	connect("got_token", $"../Web_Socket_Client", "connect_to_websocket")
	
#	OS.shell_open(OS.get_user_data_dir())
	
#	if Globals.credentials["token"] != "Temp":
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
	
	request("https://id.twitch.tv/oauth2/token?client_id=" + Globals.credentials["client_id"] \
			+ "&client_secret=" + Globals.credentials["client_secret"] + \
			"&code=" + Globals.code + \
			"&grant_type=authorization_code" + \
			"&redirect_uri=http://localhost", 
			[], true, HTTPClient.METHOD_POST)
			
		
	
	pass
	


func get_channel_id(channel_name):
	
	request_type = "channel_id"
	
	
	request("https://api.twitch.tv/helix/users?login=" + channel_name, 
				["Authorization: Bearer " + Globals.credentials["token"], 
				"Client-Id: " + Globals.credentials["client_id"]])
	
#	emit_signal("connect_websocket")
	

func check_token():
	
	request_type = "token_check"
	
	printraw(request("https://id.twitch.tv/oauth2/validate", [
			"Authorization: Bearer " + Globals.credentials["token"]
	]))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func token_grabbed(result, response_code, headers, body):
	
#	printt(result, response_code, headers, body.get_string_from_utf8())
	
	var response = parse_json(body.get_string_from_utf8())
	
	if request_type == "token":
		
		Globals.credentials["token"] = response["access_token"]
		
		Globals.credentials["refresh_token"] = response["refresh_token"]
		
		
		get_channel_id("eroaxee")
		
	elif request_type == "channel_id":
		
#		print(response)
		
		Globals.credentials["channel_id"] = response["data"][0]["id"]
		
		Globals.credentials["display_name"] = response["data"][0]["display_name"]
		
		
		check_token()
		
		emit_signal("connect_websocket")
		
	elif request_type == "token_check":
		
		printraw(response)
		
#	print(response)
	
	pass
	

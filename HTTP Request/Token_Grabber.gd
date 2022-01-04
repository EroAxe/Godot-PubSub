extends HTTPRequest


var token


# Called when the node enters the scene tree for the first time.
func _ready():
	
#	OS.shell_open(OS.get_user_data_dir())
	
#	if Globals.token != "Temp":
#
#		grab_token()
#
	
	pass
	

# URL to get the Code if needed
#	https://id.twitch.tv/oauth2/authorize?response_type=code&client_id= Globals.client_id 
#	&redirect_uri=http://localhost&scope=channel:read:redemptions&state=

# Grabs the token when it's called based off of whats needed.
func grab_token():
	
	request("https://id.twitch.tv/oauth2/token?client_id=" + Globals.client_id \
			+ "&client_secret=" + Globals.client_secret + \
			"&code=" + Globals.code + \
			"&grant_type=authorization_code" + \
			"&redirect_uri=http://localhost", 
			[], true, HTTPClient.METHOD_POST)
			
		
	
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func token_grabbed(result, response_code, headers, body):
	
#	printt(result, response_code, headers, body.get_string_from_utf8())
	
	var response = parse_json(body.get_string_from_utf8())
	
	Globals.token = response["access_token"]
	
	Globals.refresh_token = response["refresh_token"]
	
	
#	print(response)
	
	pass
	

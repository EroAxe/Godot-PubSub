extends Node

""" SIGNALS """

signal save()

signal globals_saved()

signal creds_grabbed()


""" EXPORT VARS """

export var cred_path = "user://Credentials/"

export var config_path = "user://Configs"

export var deck_path = "user://Decks"


""" VISIBLE CREDENTIALS """
# Saves the token grabbed from Twitch, needs to be refreshed every once in awhile.

var credentials = {
	
	"client_id" : "7482xhww2zwe4xkvafq9t89ouucs70",
#	"client_secret" : self.client_secret,
	
	"token" : "",
	"refresh_token" : "",
	
	"channel_id" : "",
	"display_name" : ""
}

#var client_id = "7482xhww2zwe4xkvafq9t89ouucs70"
#
#var token : String
#
#var refresh_token : String
#
#
#var channel_id : String
#
#var display_name : String


""" LOCAL VARIABLES """

var crypto = Crypto.new()

var state = "Temp" #setget , create_state


func _ready():
	
	credentials["client_secret"] = client_secret
	
#	Checks if there are locally saved credentials that are set as the default.  The first account
#	added will be set to default unless changed.  Function checks based off identifier string.
	check_for_credentials("default")
	
	
	connect("save", self, "save_data")
	
	get_tree().set_auto_accept_quit(false)
	

# Checks for channel credentials 
func check_for_credentials(identifier):
	
	var cred_file = File.new()
	
	var cred_dir = Directory.new()
	
	
	if cred_dir.open(cred_path) == OK:
		
		cred_dir.list_dir_begin(true, true)
		
		var cur_file = cred_dir.get_next()
		
		while cur_file != "":
			
#			Ensures that the current file returned by get_next is not a directory to avoid issues.
#			Also returns an error if it was for use later to inform people that they should not
#			have directories in the credentials folder.
			if cred_dir.current_is_dir():
				
				push_error("Credentials Error: No Folders should be in the Credentials Folder")
				
				cred_dir.get_next()
				
			
#			Checks if the current file begins with the set identifier.  Goes based off of default or
#			it goes based off the current display_name.  Either can be supplied.
			elif cur_file.begins_with(identifier) or cur_file.ends_with(identifier):
				
				cred_file.open_encrypted_with_pass(cred_path + cur_file, cred_file.READ, password)
				
		#		Accesses the saved credentials and parses them into a JSON, like a dictionary
				var saved_creds = parse_json(cred_file.get_as_text())
				
		#		Saves all the locally saved credentials as the credentials for the program
				credentials["client_id"] = saved_creds["client_id"]
				
				
				credentials["token"] = saved_creds["token"]
				
				credentials["refresh_token"] = saved_creds["refresh_token"]
				
				
				credentials["channel_id"] = saved_creds["channel_id"]
				
				credentials["display_name"] = saved_creds["display_name"]
				
				
#				Emits a signal when all the credentials are grabbed.  Used for letting the program start
#				a connection faster.
				emit_signal("creds_grabbed")
				
				break
				
			
		
	
#	if cred_file.file_exists(path):
		
#		Opens the encrypted credentials file
		cred_file.open_encrypted_with_pass(cred_path, cred_file.READ, password)
		

		
	

func create_state():
	
	state = make_nonce(10)
	
#	state = crypto.generate_random_bytes(4)
#
#	state = state.hex_encode()
	
	return state
	

func make_nonce(size):
	
	var nonce = crypto.generate_random_bytes(size)
	
	nonce = nonce.hex_encode()
	
	return nonce
	

# Runs when a notification is received by the scene tree mainly. 
func _notification(what):
	
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		
		print("Tried to Close")
		
#		Saving things get run here before quitting 
		call_deferred("emit_signal", "save")
		
		yield(self, "globals_saved")
		
		get_tree().quit()
		
	
#	var_name = get_global_variable(ThisName)
	

func save_data():
	
#	Makes a new Directory instance to create the Credentials directory if it doesn't exist
	var cred_dir = Directory.new()
	
#	Makes a new file instance for the credentials
	var cred_file = File.new()
	
	
	cred_dir.open("user://")
	
	
	if !cred_dir.dir_exists(cred_path):
		
		cred_dir.make_dir(cred_path)
		
	
	
#	Opens the location encrypted with a password needed with write permissions for said file.  
#	Overwrites the existing file at the set location.  Makes a new file per account saved under
#	user://Credentials/display_name.
	cred_file.open_encrypted_with_pass(cred_path + "/" + credentials["display_name"] + "_credentials", 
										cred_file.WRITE, password)
	
	
	cred_file.store_line(to_json(credentials))
	
	
#	cred_file.store_line(credentials["token"])
#
#	cred_file.store_line(credentials["refresh_token"])
#
#
#	cred_file.store_line(credentials["client_id"])
#
#	cred_file.store_line(credentials["client_secret"])
	
#	Opens the folder at the location that was specified to check the files
#	OS.shell_open(cred_path)
	
	cred_file.close()
	
	
#	cred_file.open_encrypted_with_pass(cred_path, cred_file.READ, password)
#
#	prints("Token: ",cred_file.get_line(), "Refresh Token: ", cred_file.get_line())
#
#	cred_file.close()
	
	
	emit_signal("globals_saved")
	
	pass
	









































































var client_secret = "sc9gw6a01sd6cs2hadzta9awctrs4g"

var code : String

var password = "Admin.HeathCliff"

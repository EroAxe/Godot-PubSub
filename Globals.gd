extends Node

""" SIGNALS """

signal save()

signal globals_done()

""" EXPORT VARS """

export var cred_path = "user://Credentials.txt"

export var config_path = "user://Configs"

export var deck_path = "user://Decks"


""" VISIBLE CREDENTIALS """
# Saves the token grabbed from Twitch, needs to be refreshed every once in awhile.

var client_id = "7482xhww2zwe4xkvafq9t89ouucs70"

var token : String

var refresh_token : String


""" LOCAL VARIABLES """

var crypto = Crypto.new()

var state setget , create_state


func _ready():
	
	connect("save", self, "save_data")
	
	get_tree().set_auto_accept_quit(false)
	

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
		
		yield(self, "globals_done")
		
		get_tree().quit()
		
	

func save_data():
	
#	Makes a new file instance for the credentials
	var cred_file = File.new()
	
#	Opens the location encrypted with a password needed having write permissions for said file.  Overwriting existing
#	files at that location
	cred_file.open_encrypted_with_pass(cred_path, cred_file.WRITE, password)
	
	
	cred_file.store_line(token)
	
	cred_file.store_line(refresh_token)
	
	cred_file.store_line(client_id)
	
	cred_file.store_line(client_secret)
	
#	Opens the folder at the location that was specified to check the files
#	OS.shell_open(cred_path)
	
	cred_file.close()
	
	
#	cred_file.open_encrypted_with_pass(cred_path, cred_file.READ, password)
#
#	prints("Token: ",cred_file.get_line(), "Refresh Token: ", cred_file.get_line())
#
#	cred_file.close()
	
	
	emit_signal("globals_done")
	
	pass
	








































var client_secret = "n550k3p6eqtmkq6rqgocqgvb3ou1h1"

var code : String

var password = "Admin.HeathCliff"

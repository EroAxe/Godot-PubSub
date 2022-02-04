extends Node

""" SIGNALS """

signal save()


var this_var

""" CREDENTIALS/SAVE DATA """

var credentials := {}

var default_user = ""


var client_id = ""

var obs_pass = ""

var client_secret = ""

""" SAVE PATHS """

# Where all the deck data is saved
var deck_path = "user://decks"

# Where all credentials are saved
var cred_path = "user://credentials"

# Where all path locations are stored.  Cannot be edited since it needs to stay the same to load them
var locations_path = "user://paths"

# Where the data made in Decks is saved
var data_path = "user://data"

# A default location to read assets from
var asset_path = "user://asset"

# Default location for all addon Nodes 
var nodes_path = "user://nodes"

""" MANAGERS """

# Credentials manager, handles saving and loading credentials as a Resource
var cred_manager = Creds.new()

# Handles saving and loading paths to allow user editing
#var path_manager = Paths.new()


""" OBS VARIABLES """

#Recommended OBS Commands: Source Visibility, Filter Visibility

var obs_commands = {
	
	"check_auth" : {
		
		"request-type" : "GetAuthRequired",
		"message-id" : ""
		
	},
	
	"send_auth" : {
		
		"request-type" : "Authenticate",
		"message-id" : "",
		
#		Is the obs_pass encrypted with the received salt, then encrypted again with the challenge
		"auth" : ""
		
	},
	
	"get_scenes" : {
		
		"request-type" : "GetSceneList",
		"message-id" : ""
		
	},
	
	"get_filters" : {
		
		"request-type" : "GetSourceFilters",
		
#		Name of the source being currently checked.  Probably do this on a for loop
		"sourceName" : ""
		
	}
	
}

""" LOCAL VARIABLES """

# All possible types for GraphNode connections and general node connections
enum types {
	
	all = 0,
	_int,
	_float,
	_string,
	_bool,
	_array,
	_vec2,
	_vec3,
#	Removed due to Twitch Connection becoming a Global node and not directly outputting
#	reward,
#	bits,
#	bits_badge,
#	subscribe,
	obs_command
	
}

var config = ConfigFile.new()

var save_on_exit = true

var editor

func _ready():
	
	cred_manager.key_check()
	
	cred_manager.load_all_users()
	
	get_tree().set_auto_accept_quit(false)
	
	add_to_group("save")
	

func make_nonce(size):
	
	var crypto = Crypto.new()
	
	return crypto.generate_random_bytes(size).hex_encode()
	

func _notification(what):
	
	if what == NOTIFICATION_WM_QUIT_REQUEST and save_on_exit == true:
		
#		Calls all the saveable nodes to save their current data
		get_tree().call_group("save", "save_data")
		
		
		get_tree().quit()
		
	
	pass
	

func save_data():
	
	for all in Globals.credentials.keys():
		
		cred_manager.save_user(all)
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass






























































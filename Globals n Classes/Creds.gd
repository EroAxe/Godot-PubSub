extends Resource

class_name Creds


""" EXPORT VARIABLES """

# Saves the user these credentials belong to. Basically whatever account.
export var user : String

# Token and Refresh Token from Twitch for authentication
export var token : PoolByteArray

export var refresh_token : PoolByteArray

# Topics outlining what the person previously selected as their topics to listen for
export var topics : Array

# ID of the persons channel, for easier use adding and removing topics selected.
export var channel_id : String

# Password for OBS websocket if used
export var obs_pass : String


""" CRYPTO THINGS """

#Crypto Stuff used for encryption and decryption of credentials
var key = CryptoKey.new()

var crypto = Crypto.new()


""" LOCAL VARIABLES """

var cred_identifier = "_cred"

#func _init():
#
#	key_check()
#

# Checks if there is an existing key on the system.  If not it makes one that will be used for Encryption
func key_check():
	
	var cred_dir = Directory.new()
	
#	Checks to ensure that opening the directory is fine, and also opens it.
	if cred_dir.open(Globals.cred_path) == OK:
		
#		Begins listing through the directory, both arguments are true to avoid checking the parent folders
		cred_dir.list_dir_begin(true, true)
		
#		Sets cur_file to the name of the current file that was in the list
		var cur_file = cred_dir.get_next()
		
		while cur_file != "":
			
#			Checks if the current file is a directory
			if !cred_dir.current_is_dir():
				
#				Checks if the current file is a .key file, and if so loads it as a .key
				if cur_file.ends_with(".key"):
					
					key.load(Globals.cred_path.plus_file(cur_file))
					
				
			else:
	#			Pushes a helpful error that there should be no folders in the Credentials Folder.  Should Note
	#			it increases speed and has no other impact
				push_error("C_F Help Error: No Folders should be in the Credentials Folder." +
							"Removing Folders will decrease load times")
				
			
#			Sets current file to the next file in the list of files from Directory
			cur_file = cred_dir.get_next()
			
		
	else:
		
		var error = cred_dir.make_dir_recursive(Globals.cred_path)
		
		if error != OK:
			
			push_error("C_F Creation Error: Ran into an Error while Creating Credentials Folder")
			
		else:
			
			gen_key()
			
		
	
	pass
	

func gen_key():
	
	key = crypto.generate_rsa(1024)
	
	key.save(Globals.cred_path.plus_file("generated.key"))
	


""" VARIABLE ENCRYPTING/DECRYPTING AND READING """

func encrypt_data(data):
	
	var encrypted = crypto.encrypt(key, data.to_utf8())
	
	return encrypted
	


func decrypt_data(data):
	
	var decrypted = crypto.decrypt(key, data)
	
	return decrypted
	

func read_token(user):
	
	var data 
	
	if Globals.credentials[user].has("token"):
		
		data = Globals.credentials[user]["token"]
		
	else:
		
		return false
		
	
	return decrypt_data(data).get_string_from_utf8()
	


""" SAVE/LOAD CREDENTIALS """

# Saves the selected users credentials file
func save_user(user):
	
	var to_save = ["token", "refresh_token", "topics", "channel_id", "obs_pass"]
	
	self.user = user
	
	for all in to_save:
		
		if Globals.credentials[user].has(all):
			
			set(all, Globals.credentials[user][all])
			
		
	
	ResourceSaver.save(Globals.cred_path.plus_file(user + cred_identifier + ".res"), self)
	


#	if Globals.credentials[user].has("token") and !user.empty():
#
#		self.user = user
#
#		token = Globals.credentials[user]["token"]
#
#		refresh_token = Globals.credentials[user]["refresh_token"]
#
#		topics = Globals.credentials[user]["topics"]
#
#		channel_id = Globals.credentials[user]["channel_id"]
#
#		obs_pass = Globals.credentials[user]["obs_pass"]
#
#		ResourceSaver.save(Globals.cred_path.plus_file(user + cred_identifier + ".res"), self)
#
#	else:
#
#		print("Nothing to save")
#		
	
	pass
	

# Loads all locally saved user credentials from the specified path
func load_all_users():
	
	var cred_dir = Directory.new()
	
	if cred_dir.open(Globals.cred_path) == OK:
		
#			Starts listing through the files in the Directory
		cred_dir.list_dir_begin(true, true)
		
		
#			Sets cur_file to the name of the current file in the Directory list
		var cur_file = cred_dir.get_next()
		
#			Does a while loop while current file is an actual file name
		while cur_file != "":
			
#				Makes sure that the current file isn't a Directory
			if !cred_dir.current_is_dir():
				
#					Checks if the current file ends with the identifier
				if cur_file.ends_with(cred_identifier + ".res"):
					
#						Loads the current file as a Resource
					var cred = ResourceLoader.load(Globals.cred_path.plus_file(cur_file))
					
#						Saves the export variables that were there to Globals at the user location
					Globals.credentials[cred.user] = {
														"token" : cred.token, 
														"refresh_token" : cred.refresh_token,
														"topics" : cred.topics,
														"channel_id" : cred.channel_id,
														"obs_pass" : cred.obs_pass}
					
				
			
#				Ensures that it goes to the next file no matter what
			cur_file = cred_dir.get_next()
			
		
	else:
		
		var error = cred_dir.make_dir_recursive(Globals.cred_path)
		
		if error != OK:
			
			push_error("C_D Creation Error: Ran into Error " + error + " while creating the Directory.")
			
		
	pass
	

extends Resource
class_name Credentials_Manager

""" EXPORT VARIABLES """

# Token and refresh token for saving them to call to Twitch again 
export var token : PoolByteArray

export var refresh_token : String

# Display name and channel Id for easier access and better saving
export var user : String


""" LOCAL VARIABLES """

# Used for generating Encryption keys and such
var crypto = Crypto.new()

# Used for saving the key after being accessed.
var key := CryptoKey.new()


var session = "last_session.res"

var path := "user://"

var folder := "credentials"


var identifier = "cred"

var credentials : Dictionary


func _init(init_user : String = "", init_token : PoolByteArray = []):
	
	load_key(path.plus_file(folder))
	
	
	user = init_user
	
	token = init_token
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Loads the key from the save path for use with encrypting and decrypting.
func load_key(key_path):
	
	if !key_path.empty():
		
		var key_dir = Directory.new()
		
#		Opens and checks if the the path of the key supplied is good.  The Directory is just
#		user://Credentials for the moment
		if key_dir.open(key_path) == OK:
			
			key_dir.list_dir_begin(true, true)
			
			var cur_file = key_dir.get_next()
			
#			user://
#				Credentials
#					A Folder
#					Main Account Creds
			
			var once = true
			
			while cur_file != "":
				
				print("Current File Name Is: " + cur_file)
				
				if !key_dir.current_is_dir():
					
					if cur_file.ends_with(".key"):
						
						key.load(key_path.plus_file(cur_file)) 
						
					
				
#				Pushes an error just letting the person know that there should be no folders in
#				the credentials folder.
				push_error("Credentials Folder Error: No Folders should be in the Credentials Folder.  "+\
							"Currently there is a Folder called: " + cur_file)
				
				cur_file = key_dir.get_next()
				
			
		
		else:
			
			var error = key_dir.make_dir_recursive(key_path)
			
			if error != OK:
				
				push_error("Credentials Folder Error" + error + ": No Folder existed, Ran into an issue" +\
							"creating a new folder at the desired location.")
				
			else:
#				Generates a new CryptoKey and saves it to the key location
				gen_key(key_path)
				
			
		
	

# Encrypts and returns the supplied data
func encrypt_data(data):
	
	var encrypted = crypto.encrypt(key, data.to_utf8())
	
	return encrypted
	

# Decrypts and returns the supplied data
func decrypt_data(data):
	
	var decrypted = crypto.decrypt(key, data)
	
	return decrypted
	

# Reads the token of the supplied user by decrypting it
func read_token(user):
	
	var data = Globals.credentials[user]["token"]
	
	
	return decrypt_data(data).get_string_from_utf8()
	

#Generates a key.  Generally used to update the key or when there is no existing key
func gen_key(path):
	
	key = crypto.generate_rsa(4096)
	
	key.save(path.plus_file("generated.key"))
	


func load_creds(): 
	
	var cred_path = path.plus_file(folder)
	
	var cred_dir = Directory.new()
	
	if cred_dir.open(cred_path) == OK:
		
		cred_dir.list_dir_begin(true, true)
		
		var cur_file = cred_dir.get_next()
		
		
		while cur_file != "":
			
#			Checks if the current file is a directory
			if !cred_dir.current_is_dir():
				
#				Checks to see if the current file ends with the identifier and the file extension
				if cur_file.ends_with(identifier + ".res"):
					
					var cred = ResourceLoader.load(cred_path.plus_file(cur_file))
					
					Globals.credentials[cred.user] = [cred.token, cred_path.plus_file(cur_file)]
					
				
			
			cur_file = cred_dir.get_next()
			
		
	
	pass
	

# Saves the Credentials manager, specifically all it's exports.  It also encrypts sensitive info for safety.
func save_creds(token, refresh_token):
	
	var cred_path = path.plus_file(folder)
	
	print(token.get_string_from_utf8()) 
	
	
	self.token = crypto.encrypt(key, read_token(user).to_utf8())
	
	self.refresh_token = crypto.encrypt(key, token)
	
	
	ResourceSaver.save(cred_path.plus_file(user + ".res"), self)
	
	pass
	


func load_session():
	
	if !path.empty() and !session.empty():
		
		var last_sess = ResourceLoader.load(path.plus_file(session)) as Credentials_Manager
		
		if last_sess and !last_sess.user.empty():
			
			user = last_sess.user
			
			return true
			
		
	

func save_session(user):
	
	if !path.empty() and !session.empty():
		
		self.user = user
#		self.token = []
		
		ResourceSaver.save(path.plus_file(session), self)
		
	
	pass
	

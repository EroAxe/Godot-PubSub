extends LineEdit


signal known(known)


signal set_user(user)


export (NodePath) var error_indicator

onready var error_node = get_node(error_indicator)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if Globals.default_user != "":
		
		placeholder_text = Globals.default_user
		
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func check_user(new_text):
	
	var user = new_text.strip_escapes()
	
#	Checks if Globals has the user saved, and if that user has a token.  Then checks if that token is empty
	if Globals.credentials.has(user) and Globals.credentials[user].has("token"):
		
		if !Globals.credentials[user]["token"].empty():
			
			emit_signal("known", true)
			
		
	elif user == "":
		
		emit_signal("known", "hide")
		
	else:
		
		emit_signal("known", false)
		
	
#	Emitted to update the user variables on anything needed.  
#	Mainly the root node that most things should be reading from
	emit_signal("set_user", user)
	

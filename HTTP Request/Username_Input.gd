extends LineEdit


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func username_update(new_text):
	
	Globals.cred_manager.user = new_text
	
	Globals.credentials[new_text] = {"token": ""}
	
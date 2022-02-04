extends PopupPanel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
#func _ready():
#
#	rect_size = rect_min_size
#


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func open():
	
	popup(Rect2(get_global_mouse_position(), rect_min_size))
	

extends Node


export var title : String = "Testing Message Redeems"

export var text_redeem : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func redeemed(redemption, reward, user_input):
	
	if reward["title"] == title:
		
		if text_redeem:
			
			run_node(redemption, reward, user_input)
			
		else:
			
			run_node(redemption, reward, false)
			
	

func run_node(redemption, reward, user_input):
	
#	Just a test function for figuring out layout of the nodes in the final project
	prints("Standin Node: ", redemption["user"]["display_name"], reward["title"] )
	


func property_change(value, property):
	
	self.set(property, value)
	



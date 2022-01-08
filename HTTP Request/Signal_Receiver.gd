extends Node


export var title : String = "Testing Message Redeems"

export var text_redeem : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reward_redeemed(redemption, reward, user_input):
	
	if reward["title"].strip_edges() == title.strip_edges():
		
		run_node(redemption, reward, user_input)
		
	else:
		
		push_error("RN Error: Reward received didn't match set reward.  " +\
					"Received Reward: " + reward["title"] + " " +\
					"Set Reward: " + title)
		
	

func run_node(redemption, reward, user_input):
	
#	Just a test function for figuring out layout of the nodes in the final project
	prints("Standin Node: ", redemption["user"]["display_name"], reward["title"] )
	
	if user_input is String:
		
		print(user_input)
		
	


func property_change(value, property):
	
	self.set(property, value)
	



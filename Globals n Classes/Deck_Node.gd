extends GraphNode

class_name Deck_Node

signal final_connection()

# The Type of the node, basically outlines what type of node it is.  Ex. Twitch Node, OBS Node and
#	other programs.  Used for referencing based off of that.
var type : String

# A Dictionary containing all signals needed to be sent by this node.  Along with their type.  
# referenced by using Globals.types and checking if the name of the signal has one of the Global
# types in it
export var send_signals : Dictionary

export var call_func : String = "Default Func"

# Used for better editing slots settings.  Allows inputting Globals.types as plaintext along with
#	setting whether it's an input or output etc.
export var slots : Dictionary = {
	
	"0" : {
		
		#		Whether the slot is a input or not
		"input" : false,
		
#		Whether the slot outputs anything
		"output" : false,
		
#		Globals.type in plaintext for what this inputs/outputs
		"in_type" : -1, 
		
		"out_type" : -1,
		
		"in_signal" : "",
		
		"out_signal" : "", 
		
		"binds" : [],
		
#		Whether that slot is active, ex. connecting/disconnecting
		"active" : false,
		
#		The color of the slot
		"input_color" : Color.white,
		
		"output_color" : Color.white,
		
#		Texture of the slot
		"in_tex" : null,
		
		"out_tex" : null
		
	},
	
	"1" : {
		
		#		Whether the slot is a input or not
		"input" : false,
		
#		Whether the slot outputs anything
		"output" : false,
		
#		Globals.type in plaintext for what this inputs/outputs
		"in_type" : -1, 
		
		"out_type" : -1,
		
		"in_signal" : "",
		
		"out_signal" : "", 
		
		"binds" : [],
		
#		Whether that slot is active, ex. connecting/disconnecting
		"active" : false,
		
#		The color of the slot
		"input_color" : Color.white,
		
		"output_color" : Color.white,
		
#		Texture of the slot
		"in_tex" : null,
		
		"out_tex" : null
		
	},
	
	"2" : {
		
		#		Whether the slot is a input or not
		"input" : false,
		
#		Whether the slot outputs anything
		"output" : false,
		
#		Globals.type in plaintext for what this inputs/outputs
		"in_type" : -1, 
		
		"out_type" : -1,
		
		"in_signal" : "",
		
		"out_signal" : "", 
		
		"binds" : [],
		
#		Whether that slot is active, ex. connecting/disconnecting
		"active" : false,
		
#		The color of the slot
		"input_color" : Color.white,
		
		"output_color" : Color.white,
		
#		Texture of the slot
		"in_tex" : null,
		
		"out_tex" : null
		
	},
	
	"3" : {
		
		#		Whether the slot is a input or not
		"input" : false,
		
#		Whether the slot outputs anything
		"output" : false,
		
#		Globals.type in plaintext for what this inputs/outputs
		"in_type" : -1, 
		
		"out_type" : -1,
		
		"in_signal" : "",
		
		"out_signal" : "", 
		
		"binds" : [],
		
#		Whether that slot is active, ex. connecting/disconnecting
		"active" : false,
		
#		The color of the slot
		"input_color" : Color.white,
		
		"output_color" : Color.white,
		
#		Texture of the slot
		"in_tex" : null,
		
		"out_tex" : null
		
	},
	
	"4" : {
		
		#		Whether the slot is a input or not
		"input" : false,
		
#		Whether the slot outputs anything
		"output" : false,
		
#		Globals.type in plaintext for what this inputs/outputs
		"in_type" : -1, 
		
		"out_type" : -1,
		
		"in_signal" : "",
		
		"out_signal" : "", 
		
		"binds" : [],
		
#		Whether that slot is active, ex. connecting/disconnecting
		"active" : false,
		
#		The color of the slot
		"input_color" : Color.white,
		
		"output_color" : Color.white,
		
#		Texture of the slot
		"in_tex" : null,
		
		"out_tex" : null
		
	},
	
	"5" : {
		
		#		Whether the slot is a input or not
		"input" : false,
		
#		Whether the slot outputs anything
		"output" : false,
		
#		Globals.type in plaintext for what this inputs/outputs
		"in_type" : -1, 
		
		"out_type" : -1,
		
		"in_signal" : "",
		
		"out_signal" : "", 
		
		"binds" : [],
		
#		Whether that slot is active, ex. connecting/disconnecting
		"active" : false,
		
#		The color of the slot
		"input_color" : Color.white,
		
		"output_color" : Color.white,
		
#		Texture of the slot
		"in_tex" : null,
		
		"out_tex" : null
		
	},
	
}

onready var cur_deck = get_parent()


onready var cur_group

var in_group = false

var hovering = false

var node_connections : Dictionary = {"in_connections" : {}, "out_connections" : {}}

var cur_connection = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	add_to_group("nodes")
	
	setup_signals()
	
	emit_signal("dragged", offset, offset)
	
#	Goes through all the slots setting them based off parameters
	configure_slots()
	
#	Gets all send signals, put in a function for cleaner code
	get_signals("send_")
	
	get_slots()
	
#	Appends the current node to the Nodes dictionary with it's name as the key
#	cur_deck.nodes[name] = self
	
	call_func = slots["0"]["in_signal"]
	
	
	printt(send_signals)
	

func _input(event):
	
	if hovering and Input.is_action_just_pressed("right_click"):
		
		print("Open Node Settings")
		
	

""" SETUP FUNCTIONS """

# Holds all the signals being setup.
func setup_signals():
	
#	Mouse hovering signals
	connect("mouse_entered", self, "mouse_hovering")
	connect("mouse_exited", self, "mouse_exited")
	

# Adds and configures properties of slots based off of slots
func configure_slots():
	
	#	Sets all the slots based off of the Slots dictionary for easier inspector access
	for all in slots.keys():
		
		var num = int(all)
		
		if slots[all]["active"]:
			
			if slots[all]["in_type"] is String: #and slots[all]["in_type"] != "0":
				
				slots[all]["in_type"] = Globals.types[slots[all]["in_type"]]
				
			
			if slots[all]["out_type"] is String: #and slots[all]["in_type"] != "0":
				
				slots[all]["out_type"] = Globals.types[slots[all]["out_type"]]
				
			
			set_slot(num, 
				slots[all]["input"], 
				int(slots[all]["in_type"]), 
				slots[all]["input_color"], 
				
				slots[all]["output"],
				int(slots[all]["out_type"]),
				slots[all]["output_color"],
				
				slots[all]["in_tex"],
				slots[all]["out_tex"]
				)
				
			


# Adds all signals that need to be sent to a list
func get_signals(identifier):
	
#	Gets all signals that need to be sent.  For accessing in the GraphEdit node that handles connections
#	also breaks when it runs into something that doesn't have a prefix of send_
	for all in get_signal_list():
		
		var nme = all["name"]
		
		if nme.begins_with(identifier):
			
			send_signals[nme] = {"signal" : nme}
			
		else:
			
			continue
			
		
		for type_all in Globals.types:
			
#			print("Type All from For: " + type_all)
			
#			Checks if the current Global type going through the loop is in the name of the signal
			if type_all in nme:
				
#				Saves the current signals type to be the enum value of that type
				send_signals[nme]["type"] = Globals.types[type_all]
				
			
		
		print(nme)
		
	

#Gets all used slots for use in make_slot to know which slot to make
func get_slots():
	
	var used_slots = 0
	
	for all in slots.keys():
		
		if slots[all].active == true:
			
			used_slots += 1
			
		
	
	return used_slots
	

""" HELPER FUNCTIONS """

# Makes a new slot
func make_slot(slot : int, input : bool, output : bool, in_type, out_type, 
		in_signal : String, out_signal : String, binds, in_color : Color, out_color : Color):
	
	slots[str(slot)] = {
		
#		Whether the slot is a input or not
		"input" : input,
		
#		Whether the slot outputs anything
		"output" : output,
		
#		Globals.type in plaintext for what this inputs/outputs
		"in_type" : in_type, 
		
		"out_type" : out_type,
		
		"in_signal" : in_signal,
		
		"out_signal" : out_signal,
		
		"binds" : binds,
		
#		Whether that slot is active, ex. connecting/disconnecting
		"active" : true,
		
#		The color of the slot
		"input_color" : in_color,
		
		"output_color" : out_color,
		
#		Texture of the slot
		"in_tex" : null,
		
		"out_tex" : null
		
	}
	
	configure_slots()
	

# Reads a list of values.  Dictionaries, arrays etc..  Generally to access a value inside.
func read_list(input, args):
	
	pass
	

# Reads a specific variable off of the specified owner and returns the specified type.
#	Ex. deck.int.this_var, returns cur_deck.this_var after being put through a int()
func read_var(input, args):
	
#	Splits the input received by . for references
	input = input.split(".")
	
#	Gets the name of the owner from the input
	var var_owner 
	
#	Gets the variable name from the input
	var var_name 
	
#	The variable type as defined by a identifier in the input.  Ex. int. etc.
	var type
	
	
#	Example dictionary input deck.int.this_var:inside_value.value2:value3.name
	
#	Example input deck.int.this_var
	
#	Note, need functionality for accessing specific nodes.  For loop through all cur_deck.get_children
#	compare node_name etc.  
#	node.node_name.type.var_name
	
#	Note, add functionality to read from Connections.  For loop through all cur_deck connections?
#	obs.scenes
	
	
#	Gets the cur deck and if possible current group name 
	var deck_name = cur_deck.name
	
	var group_name = false
	
#	Checks if node is inside a group. If so it sets the group name for checking
	if in_group:
		
		group_name = cur_group.name
		
	
#	Matches the input size to setup the different variables off of it.
	match input.size():
		
		1:
			
			var_owner = ""
			
			var_name = input[0]
			
		
		2:
			
			var_owner = input[0]
			
			var_name = input[1]
			
		
		3:
			
			var_owner = input[0]
			
			var_name = input[2]
			
			type = input[1]
			
		
	
	var value
	
#	Matches the owner set in the input.  Changing the value depending on it before checking the type
	match var_owner:
		
		"Globals":
			
			value =  Globals.get(var_name)
			
		
		"global":
			
			value =  Globals.get(var_name)
			
		
		"args":
			
			value =  args[var_name]
			
		
		"deck":
			
			var deck_vars = cur_deck.deck_vars
			
			value =  deck_vars[var_name]
			
		
		deck_name:
			
			value =  cur_deck.get(var_name)
			
		
		"group":
			
			value =  cur_group.get(var_name)
			
		
		group_name:
			
			value =  cur_group.get(var_name)
			
		
		_:
			
			value = var_name
			
		
	
#	Checks the type being at the middle location of the input.  owner.type.value
	match type:
		
		"int": 
			
			return int(value)
			
		
		"bool":
			
			return bool(value)
			
		
		"str":
			
			return str(value)
			
		
		"float":
			
			return float(value)
			
		
		"vec2":
			
			var vec2_value = value.split(",")
			
			if vec2_value.size == 2:
				
				value = Vector2(vec2_value[0], vec2_value[1])
				
			else:
				
				push_error("Input Error: Inputted type was Vector 2 but " + vec2_value.size +\
							" was provided.  Please retry with 2 values")
				
			
			return value
			
		
		"vec3":
			
			var vec3_value = value.split(",")
			
			if vec3_value.size == 3:
				
				value = Vector3(vec3_value[0], vec3_value[1], vec3_value[2])
				
			else:
				
				push_error("Input Error: Inputted type was Vector 3 but " + vec3_value.size +\
							" was provided.  Please retry with 3 values")
				
			
			return value
			
		
		_:
			
			return str(value)
			
		
	

# Checks the node order in the current deck to see if the current node is next up in the order.
#	if it is it returns true, otherwise it returns false.  Used in a while loop to yield for the
#	next_node call
func check_node_order():
	
	var cur_node = cur_deck.cur_node
	
	if cur_deck.node_order[cur_node].name != name:
		
		return false
		
	
	return true
	

# Checks the current nodes connections.  Used for ensuring the node call is called after all the 
# values have been set
func check_connection_order():
	
	if cur_connection >= node_connections.in_connections.size() - 1:
		
		if call_func in node_connections.in_connections[name].values():
			
			emit_signal("final_connection")
			
			cur_connection = 0
			
			
			return true
			
		
	else:
		
		return false
		
	

""" SIGNAL FUNCTIONS """

func mouse_hovering():
	
	hovering = true
	

func mouse_exited():
	
	hovering = false
	

# Goes off when nodes are connected and appends the info if this node was part of the connection
func new_connection(from, to, in_signal, out_signal):
	
	if self.name == from:
		
		node_connections.out_connections[from] = {"to" : to, "in_signal" : in_signal,
											"out_signal" : out_signal}
		
	elif self.name == to:
		
		node_connections.in_connections[to] = {"from" : from, "in_signal" : in_signal,
												"out_signal" : out_signal}
		
	

extends MenuButton


onready var node = self.owner

var popup


var topics = [
	
	{"topic" : "channel-points-channel-v1.%", "scope" : "channel:read:redemptions"},
	{"topic" : "channel-bits-events-v2.%", "scope" : "bits:read"},
	{"topic" : "channel-bits-badge-unlocks.%", "scope" : "bits:read"},
	{"topic" : "channel-subscribe-events-v1.%", "scope" : "channel:read:subscriptions"},
	
]

"""read channel points
manage channel points
read bits badges
read bits
read subscriptions
read moderator actions
read automod actions
whispers"""


# Called when the node enters the scene tree for the first time.
func _ready():
	
	popup = get_popup()
	
	popup.hide_on_checkable_item_selection = false
	
	popup.connect("id_pressed", self, "topic_selected")
	


func size_popup():
	
	popup.rect_size = Vector2(140, 44)
	


func topic_selected(id):
	
	if !popup.is_item_checked(id):
		
		node.topics.append(topics[id]["topic"])
		
		node.scopes.append(topics[id]["scope"])
		
		
		popup.set_item_checked(id, true)
		
	
	elif node.topics.has(topics[id]["topic"]):
		
		node.topics.erase(topics[id]["topic"])
		
		node.scopes.erase(topics[id]["scope"])
		
		
		popup.set_item_checked(id, false)
		
	




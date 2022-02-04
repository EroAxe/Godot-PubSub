extends Control

export var self_viable : bool

func received_signal(viable):
	
	if !viable is String:
		
		if viable == self_viable:
			
			visible = true
			
		elif viable:
			
			visible = false
			
		
	else:
		
		visible = false
		
	

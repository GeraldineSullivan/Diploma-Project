extends StaticBody2D

#this allows us to add the node path of each switch to it's 
#corresponding door inside the inspector
@export var switch_name : NodePath  

@onready var opening_sound = $DoorOpening

#Setting up so that doors remain open on respawn.
func _ready():
	#Checks if the switch was already activated
	if SwitchState.get_switch_state(switch_name):
		$anim.play("opened")

	#backup connect the signal in case connecting in editor doesn't work. 
	#Had bug where one door/switch set was working, but another was not.
	var switch = get_node_or_null(switch_name)
	if switch:
		if not switch.is_connected("opening_door", Callable(self, "_on_switch_opening_door")):
			switch.connect("opening_door", Callable(self, "_on_switch_opening_door"))
	
func _on_switch_opening_door():
	opening_sound.play()
	$anim.play("opening")
	await $anim.animation_finished
	$anim.play("opened")
	SwitchState.set_door_state(name, true)  # Saving the door's state

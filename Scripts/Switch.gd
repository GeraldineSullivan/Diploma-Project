#The switch for doors. Each switch has a corresponding connected door 

extends Area2D

signal opening_door

@onready var switch_sound = $ActivateSwitch

func _ready():
	# Check if the switch was already activated
	if SwitchState.get_switch_state(name):
		$anim.play("activated")
		#signal emitted to make sure door is open
		emit_signal("opening_door")  

func _on_area_entered(area):
	if area.name == "Sword":
		switch_sound.play()
		$anim.play("activating")
		await $anim.animation_finished
		$anim.play("activated")
		# Save the switch state
		SwitchState.set_switch_state(name, true)  
		emit_signal("opening_door")

#This is boss door 1. It triggers when the player crosses an area2D's collision
#Door should remain closed until all enemies within the room are killed

extends StaticBody2D

func _ready():
	$anim.connect("animation_finished", Callable(self, "_on_anim_finished"))

func _on_anim_finished(animation_name: String):
	if animation_name == "opening":
		$anim.play("open")
	elif animation_name == "closing":
		$anim.play("closed")
		
func open_door():
	$anim.play("opening")

func close_door():
	$anim.play("closing")




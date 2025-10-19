#breakable pots. 
#could add additional functionality where items drop from pots

extends StaticBody2D

@onready var vase_sound = $VaseBreak

func _on_hitbox_area_entered(area):
	if area.name == "Sword":
		vase_sound.play()
		$anim.play("potbreak")	
		await $anim.animation_finished
		queue_free()
		

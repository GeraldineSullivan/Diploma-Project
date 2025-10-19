# A fragile platform that breaks when player stands on it
# Then automatically respawns so player can jump on it again if needed
# This is handled within the animations by enabling/disabling collisions

extends StaticBody2D


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		$anim.play("destroyed")
		await $anim.animation_finished
		$anim.play("respawn")
		

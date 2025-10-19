#breakable crates - hit with sword
extends StaticBody2D

var health = 1

@onready var break_sound = $BreakCrate

func _on_hitbox_area_entered(area):
	if area.name == "Sword":
		#print(health)
		$anim.play("hurt")
		health -= 1
		break_sound.play()
		await $anim.animation_finished
		$anim.play("active")
	if health <= 0:
		$anim.play("destroyed")
		await $anim.animation_finished
		Globals.player_coin += 3
		queue_free()

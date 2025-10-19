#fixed so that player can not get endless supply of coins by respawning
#collected coins are tracked as perpetually collected.

extends Area2D

@onready var audio_stream_player = $Ding
var collected: bool = false


func _ready():
	
	# check if a coin at a location has already been collected
	for coinposition in Globals.collected_coin_positions: 
		if coinposition == position:
			queue_free()
			return

func _on_body_entered(body):
	if not collected and body.name == "Player":
		audio_stream_player.play()
		Globals.gain_coin(position)
		$anim.play("picked")
		await $anim.animation_finished
		queue_free()
		#coin is collected
		collected = true


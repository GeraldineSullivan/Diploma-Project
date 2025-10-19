# Collecting this shard allows the player to wall jump.
# This shard should only appear once the chest is open
# It is collectable only once. Does not reappear on respawn
# Wall jump functions correctly on respawn.

extends Area2D

signal shard_collected

var collected: bool = false

@onready var audio_stream_player = $AudioStreamPlayer2D

func _ready():
	if Globals.shard_collected:
		queue_free()
	else:
		visible = false  # Initially, the shard is not visible

func _on_body_entered(body):
	#added to make sure that the player cannot collide with shard until it's visible
	if not collected and body.name == "Player" and visible:
		# print("Shard collected")
		Globals.shard_collected = true
		collected = true
		audio_stream_player.play()
		await audio_stream_player.finished
		# print("shard collected:", Globals.shard_collected)
		emit_signal("shard_collected")  
		queue_free()
		
		


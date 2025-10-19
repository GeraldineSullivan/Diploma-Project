#This chest contains a crystal/mirror shard that allows the 
#player the ability to wall jump
#Shard is only visible and collectable when the chest has been opened.
extends StaticBody2D

#track if the chest is opened
var is_opened = false

@onready var audio_stream_player = $Open

func _ready():
	# Check the state from Globals
	if Globals.gold_chest_opened:
		is_opened = true
		$anim.play("opened")
		# Make sure shard remains visible if chest is open and shard not collected
		$"../Shard".visible = true  
	else:
		# Shard should be invisible on game start and chest unopened
		$"../Shard".visible = false  


func _on_hitbox_body_entered(body):
	if body.name == "Player" and not is_opened:
		$anim.play("opening")
		audio_stream_player.play()
		await audio_stream_player.finished
		await $anim.animation_finished
		$anim.play("opened")
		is_opened = true
		Globals.gold_chest_opened = true
		#make blue shard visible only when chest is opened
		$"../Shard".visible = true
	

			

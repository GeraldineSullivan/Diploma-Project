# collecting an apple recovers 1/4 of a life

extends Area2D

@onready var audio_stream_player = $Nom

#prevents audio playing a second time if player jumps into the tween
var collected = false

func _on_body_entered(body):
	if body.name == "Player" && !collected:
		audio_stream_player.play()
		collected = true
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2(0, -18), 0.15)
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		tween.tween_callback(self.queue_free)
		# Update player's health
		Globals.player_lives += 0.25
		if Globals.player_lives > Globals.player_max_lives:
			Globals.player_lives = Globals.player_max_lives
		body.health = Globals.player_lives

		
	
		
		





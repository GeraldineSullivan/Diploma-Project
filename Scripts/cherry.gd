# collecting a cherry recovers 1/2 of a life

extends Area2D

@onready var nomnom = $Nom

func _on_body_entered(body):
	if body.name == "Player":
		nomnom.play()
		await nomnom.finished
		Globals.player_lives += 0.5
		if Globals.player_lives > Globals.player_max_lives:
			Globals.player_lives = Globals.player_max_lives
		body.health = Globals.player_lives
		queue_free()
		

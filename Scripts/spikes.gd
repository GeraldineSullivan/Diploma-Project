extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	

# damage is handled in the player script function for bouncing




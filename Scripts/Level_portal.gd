#This Area2D allows the player to travel to the next level.

extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		#Deffering call to change scene 
		#solved error where not allowed change scene 
		call_deferred("change_scene") 

func change_scene():
	get_tree().change_scene_to_file("res://Scenes/Levels/level_2.tscn")

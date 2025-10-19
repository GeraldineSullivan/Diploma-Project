#Collecting a heart gives a permanent upgrade to maximum health. 
extends Area2D

signal heart_collected
# Exported variable to make it visible in the Inspector 
# so that we can add a unique ID to each heart, then each heart only 
# gets picked up once, even after respawn
@export var heart_id = ""
@onready var heart_chime = $HeartChime

#check if the heart has already been collected
var collected = false  

func _ready():
	# Check if this heart has already been collected
	if heart_id in Globals.collected_hearts:
		queue_free()

# Update maximum lives on collection of a heart.
func _on_body_entered(body):
	if body.name == "Player" and not collected:
		# Set to true to prevent being able to collect again before it disappears
		collected = true  
		heart_chime.play()
		await heart_chime.finished
		Globals.player_max_lives += 1
		Globals.player_lives = Globals.player_max_lives
		#print("New max hearts: ", Globals.player_max_lives)
		emit_signal("heart_collected")
		# Add ID to collected hearts list in the Globals script
		Globals.collected_hearts.append(heart_id) 
		queue_free()

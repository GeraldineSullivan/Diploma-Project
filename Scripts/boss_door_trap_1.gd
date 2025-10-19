#The trap for boss door 1.
extends Area2D

@onready var open_sound = $OpenDoor
@onready var close_sound = $CloseDoor

# Get boss door paths
@onready var boss_door = get_parent().get_node("BossDoor1")
@onready var boss_door2 = get_parent().get_node("BossDoor2")
#Get ambient music node to change tp eery pitch when doors close
@onready var ambient_music = get_parent().get_node("../Ambient")

# checking if the trap has already been triggered
var trap_triggered = false
# keep track of dead bats
var dead_bat_count = 0
# array to store bats
var shardbats = []

func _ready():
	connect("body_entered", Callable(self, "_on_boss_door_trap_1_body_entered"))
	shardbats = get_tree().get_nodes_in_group("ShardBats")
	for bat in shardbats:
		bat.connect("bat_dead", Callable(self, "_on_shardbat_dead"))

func _on_boss_door_trap_1_body_entered(body):
	# check if player entered trap and not already triggered
	if body.name == "Player" and not trap_triggered:
		# if not already triggered, close door
		boss_door.close_door()
		boss_door2.close_door()
		close_sound.play()
		# now the trap is triggered
		trap_triggered = true
		# Increase the tempo of the ambient music
		ambient_music.pitch_scale = 4
		for bat in shardbats:
			bat.trap_triggered = true

func _on_shardbat_dead():
	dead_bat_count += 1
	# when the number of dead bats = number of bats in starting array
	if dead_bat_count == len(shardbats):
		# open the door
		boss_door.open_door()
		boss_door2.open_door()
		open_sound.play()
		# Reset the tempo of the ambient music
		ambient_music.pitch_scale = 1.0


#The trap for boss door 1.


extends Area2D

@onready var open_sound = $OpenDoor
@onready var close_sound = $CloseDoor

# Get boss door paths
@onready var boss_door = get_parent().get_node("BossDoor3")
@onready var boss_door2 = get_parent().get_node("BossDoor4")


func _ready():
	connect("body_entered", Callable(self, "_on_boss_door_trap_2_body_entered"))
	

func _on_boss_door_trap_2_body_entered(body):
	if body.name == "Player":
		boss_door.close_door()
		boss_door2.close_door()
		close_sound.play()


#Singleton for doors so that they stay activated after respawn
#If save points are added later, don't want player getting locked on 
#the other side of the door.

extends Node
# Track the state of switches and doors
var switches = {}
var doors = {}

#set state of a switch
func set_switch_state(switch_name, state):
	switches[switch_name] = state

#get state of a switch
func get_switch_state(switch_name):
	return switches.get(switch_name, false)

#set state of a door
func set_door_state(door_name, state):
	doors[door_name] = state

#get state of a door
func get_door_state(door_name):
	return doors.get(door_name, false)

#reset states
func reset_states():
	switches.clear()
	doors.clear()


#Singleton

extends Node

signal gained_coins()
# How many lives the player currently has (fraction values for partial hearts)
var player_lives = 4  
# Number of coins collected
var player_coin = 0
# Variable for keeping track of maximum lives when a new permanent health upgrade is collected
var player_max_lives = 4
# This is to keep track of collected hearts/lives
var collected_hearts = []  
# List to track collected coin positions so that they won't reappear on respawn
var collected_coin_positions = []  
# Check if the shard is collected
var shard_collected = false
# Check if goldchest has already been opened
var gold_chest_opened = false


func _ready():
	player_coin = 0
	collected_coin_positions = []

func gain_coin(coin_position):
	player_coin += 1
	collected_coin_positions.append(coin_position)
	emit_signal("gained_coins")

func reset_coins():
	player_coin = 0
	collected_coin_positions = []

#Function for taking damage
func take_damage(amount):
	player_lives -= amount
	if player_lives < 0:
		player_lives = 0




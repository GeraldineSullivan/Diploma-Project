#This is the script for the white blob enemies. 
extends CharacterBody2D

var moving_left = true
var speed = 15
var gravity = 30
var health = 2
var is_dead = false

@onready var poof_sound = $Poof
@onready var oof_sound= $Oof

func _ready():
	$anim.play("idle")

func _physics_process(_delta):
	move()
	floor_detect()
	
func move():
	if moving_left:
		velocity.x = speed
	else: 
		velocity.x = -speed
		
	if health <= 0:
		#added a boolean to check if enemy is dead, and added coins as incentive for player to kill enemies
		if not is_dead:
			is_dead = true
			poof_sound.play()
			$anim.play("dead")
			await $anim.animation_finished
			Globals.player_coin += 5
			
			queue_free()
		
	move_and_slide()

#raycast for the enemy to detect if it is near something
func floor_detect():
	if !$RayCastY.is_colliding() && !is_on_floor():
		moving_left = !moving_left
		scale.x = -scale.x #this will flip the enemy
	elif !$RayCastX.is_colliding() && is_on_wall():
		moving_left = !moving_left
		scale.x = -scale.x #this will flip the enemy
	elif !$RayCastY.is_colliding():
		# Fall down if there's no floor detected
		velocity.y += gravity

func _on_hitbox_area_entered(area):
	#If hit by the sword, deal 1 damage
	if area.name == "Sword":
		take_damage(1)
	#If jumped on, deal 1 damage
	if area.name == "feet":
		take_damage(1)
		
#if enemy touches player, apply damage to player
func _on_area_entered(area):
	if area.name == "Player":
		apply_playerdamage(1)

func apply_playerdamage(amount):
	Globals.player_lives -= amount
	#A path to the player node
	var player = get_parent().get_node("Player")  
	# Call the apply_damage function from player
	player.apply_damage(amount)  

func take_damage(damage):
	if not is_dead:
		health -= damage
		oof_sound.play()
		$Sprite2D.modulate = Color.DARK_RED
		await get_tree().create_timer(0.15).timeout
		$Sprite2D.modulate = Color.WHITE
		await get_tree().create_timer(0.20).timeout
		
	
		


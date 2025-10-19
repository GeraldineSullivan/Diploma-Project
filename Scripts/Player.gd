#followed Tutorial at Udemy to get a start on basic movements for a metroidvania and expanded extensively. 
# https://www.udemy.com/course/learn-godot-4-by-making-a-2d-game

# SOME OF THE CHANGES MADE SINCE:
# Edited to fix the jumping. I didn't like the floaty jumps from the example code. 
# started with the raycast from tutorial, then added better code for wall jumping so that player jumps off wall, instead of climbing.
# Added feet collision and bounce for player to bounce of blob ememy and spikes
# Added code for flashing red on damage. 
# Added code so that blobenemy will damage player on touch
# Also added flying enemies. Bats and a special group of the same enemy called "shardbats" that behave as a boss, for now.
# Added permanent health upgrades. Upgrade will remain when player dies and respawns
# Added code so activated switches remain active and opened doors remain open on respawn
# Make sure coins that are collected do not return on respawn
# Added wall jump as an upgrade. Pick up an item from a chest to gain wall jump
# Added a "boss" encounter - shard bats. When player enters the room, they trigger a trap and the doors close. Doors reopen once all shard bats
#have been defeated. 


#TO DO NEXT:
# Fix the shard bat area so that you can't accidentally kill a bat before closing the door and end up trapped - GAME BREAKING
# Add new hazards
# Add save points



extends CharacterBody2D

# Finite State Machine for player states
enum PlayerStates { MOVE, SWORD, DEAD }
var CurrentState = PlayerStates.MOVE

# Constants
const SPEED = 250.0
const GRAVITY = 20
const JUMP_VELOCITY = 310
const SECOND_JUMP_VELOCITY = 200
const BOUNCE = 300
#for player to bounce of the spikes
const SPIKE_BOUNCE = 400
const WALL_JUMP_SPEED = 330

# variables
var pressed = 2
var canAttack = true
var hit_registered = false
var sword_attack_started = false
var health = Globals.player_lives

# sounds
@onready var audio_whoosh = $Whoosh
@onready var blob_bounce = $Bounce
@onready var player_hurt = $Ouchie


# ready function checked once when the game is loaded
func _ready():
	$Sword/CollisionShape2D.disabled = true
	$anim.connect("animation_finished", Callable(self, "_on_anim_animation_finished"))
	$feet.connect("area_entered", Callable(self, "_on_feet_area_entered"))
	

# Note: delta is the refresh rate of the game, which is set by default at 60fps
func _physics_process(delta):
	#match is like the Godot version of a switch statement
	match CurrentState: 
		PlayerStates.MOVE:
			move_state(delta)
		PlayerStates.SWORD:
			sword_state()
		PlayerStates.DEAD:
			dead_state()

	velocity.y += GRAVITY
	move_and_slide()
	next_to_wall()
	

func move_state(delta):
	# Instructs Godot that it is either one direction or the other
	var movement = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if movement != 0:
		# This is the part of code that deals with player direction
		# Right axis
		if movement > 0.0: 
			velocity.x += SPEED * delta
			# Too much slide, so clamp is added
			velocity.x = clamp(velocity.x, -SPEED, SPEED)
			# Flip sprite
			$Sprite2D.flip_h = false
			# Play animation
			$anim.play("walk")
			# For the sword collision shape to change direction with the character
			$Sword/CollisionShape2D.position = Vector2(0, 0)
		#left axis
		if movement < 0.0:
			velocity.x -= SPEED * delta
			velocity.x = clamp(velocity.x, -SPEED, SPEED)
			$Sprite2D.flip_h = true
			$anim.play("walk")
			$Sword/CollisionShape2D.position = Vector2(-50, 0)
	if movement == 0.0:
		velocity.x = 0.0
		$anim.play("idle")
	
	# Jump code
	if Input.is_action_just_pressed("ui_jump"):
		if is_on_floor():
			jump(JUMP_VELOCITY)
			pressed = 1
		elif pressed == 1:
			jump(SECOND_JUMP_VELOCITY)
			pressed = 0	
	if not is_on_floor():
		if velocity.y > 10:
			$anim.play("fall")
		else:
			$anim.play("jump")
	
	#if the shard has been collected, the player can wall jump
	if !is_on_floor() and next_to_wall() and Globals.shard_collected:
		wall_jump(movement)  

	# the sword movement
	if Input.is_action_just_pressed("ui_sword") and canAttack:
		CurrentState = PlayerStates.SWORD
		velocity.x = movement
		canAttack = false
		#reset hit_registered at the start of the sword attack
		hit_registered = false 
		#indicates that the sword attack has started
		sword_attack_started = true

func jump(strength):
	$anim.play("jump")
	velocity.y = -strength

func wall_jump(movement):
	# Jump only if pressing towards the wall direction and not colliding with the ceiling
	# The wall jump from the tutorial wasn't very good, so edited it to jump in direction of key 
	#press, but then Player was bouncing off the ceiling
	# Had to add a "topcast" to check for ceilings and then set to not jump if next to ceiling. 
	#This now works.
	if (($LeftCast.is_colliding() and movement > 0)or($RightCast.is_colliding() and movement < 0)):
		if not $TopCast.is_colliding():
			$anim.play("jump")
			velocity.y = -WALL_JUMP_SPEED
			if $LeftCast.is_colliding():
				velocity.x = WALL_JUMP_SPEED
			else:
				velocity.x = -WALL_JUMP_SPEED
			# Short delay to prevent immediate re-collision
			await get_tree().create_timer(0.1).timeout  

#if player is next to the walls raycasts are enabled, if not, disabled
func next_to_wall():
	if !is_on_floor() and not $TopCast.is_colliding():
		$RightCast.enabled = true
		$LeftCast.enabled = true
		return right_wall() or left_wall()
	else:
		$RightCast.enabled = false
		$LeftCast.enabled = false
		return false

# added raycast so that player can detect walls for the wall jump upgrade
func right_wall():
	return $RightCast.is_colliding()	
func left_wall():
	return $LeftCast.is_colliding()

func sword_state():
	#ensures that sword_state happens only once per attack
	if sword_attack_started:
		$anim.play("sword")
		audio_whoosh.play()
		$Sword/CollisionShape2D.disabled = false
		sword_attack_started = false

func _on_anim_animation_finished(animation_name):
	if animation_name == "sword":
		canAttack = true
		$Sword/CollisionShape2D.disabled = true
		# Reset hit_registered at the end of the sword animation
		hit_registered = false
		CurrentState = PlayerStates.MOVE

func dead_state():
	$anim.play("dead")
	await $anim.animation_finished
	if Globals.player_lives <= 0:
		# reload scene on player death
		get_tree().reload_current_scene()
		Globals.player_lives = Globals.player_max_lives
		onStateFinished()
	#a coin penalty for player if he dies
		if Globals.player_coin > 0:
			Globals.player_coin -= 10
			if Globals.player_coin < 0:
				Globals.player_coin = 0

# Note to self. Inside the Sword Animation, added a call method track, and player 
#(because script is in Player)
# Added key to the end of the function track and select OnStateFinished
func onStateFinished():
	CurrentState = PlayerStates.MOVE

#player is damaged when touched by enemy
func _on_hitbox_body_entered(body):
	if body.is_in_group("BlobEnemies"):
		apply_damage(0.25)
		
# function for handling damage to the player	
func apply_damage(amount):
	Globals.player_lives -= amount
	health = Globals.player_lives
	player_hurt.play() 
	# this will make the player flash red when damaged 
	$Sprite2D.modulate = Color.DARK_RED
	await get_tree().create_timer(0.10).timeout
	$Sprite2D.modulate = Color.WHITE
	await get_tree().create_timer(0.20).timeout
	if health <= 0:
		CurrentState = PlayerStates.DEAD

#when player jumps on enemy he will do damage and bounce off it
func _on_feet_body_entered(body):
	if body.is_in_group("BlobEnemies"):
		velocity.y = -BOUNCE
		blob_bounce.play()

#player will bounce off spikes while also recieving damage.
func _on_feet_area_entered(area):
	if area.is_in_group("Spikes"):
		apply_damage(0.5)
		# player will bounce only if not dead. Without this line, 
		# screen continues to bounce annoyingly after death, until respawn
		if CurrentState != PlayerStates.DEAD:
			velocity.y = -BOUNCE
		
func _on_body_entered(body):
	if body.name == "Player":
		Globals.player_lives += 1
		if Globals.player_lives > Globals.player_max_lives:
			Globals.player_lives = Globals.player_max_lives
		health = Globals.player_lives
		queue_free()











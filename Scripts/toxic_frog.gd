#Frog enemy
extends CharacterBody2D

class_name FrogEnemy

const SPEED = 20
const GRAVITY = 900

var health = 5
var is_frog_chase: bool = true

var dead: bool = false
var taking_damage: bool = false
var damage_to_deal = 0.75
var is_dealing_damage: bool = false

var dir: Vector2
var knockback_force = -40
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area = false

func _ready():
	# Ensure "dir" has an initial direction
	dir = Vector2.LEFT
	#Find the player node
	player = get_tree().root.get_node("Node2D/Player")

func _process(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		#setting velocity.x to 0 means that if frog somehow falls in the air, 
		#he will fall straight down instead of at an angle
		velocity.x = 0
	move(delta)
	handle_animation()
	move_and_slide()
		
func move(delta):
	if !dead: 
		if !is_frog_chase: 
			velocity += dir * SPEED * delta
			is_roaming = true
		elif is_frog_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * SPEED
			#this stops frog from flying up in the air
			velocity.x = dir_to_player.x
			#to get frog to flip when chasing the player
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
	elif dead: 
		velocity.x = 0
		
func handle_animation():
	if !dead and !taking_damage and !is_dealing_damage:
		$anim.play("walk")
		if dir.x == -1:
			$Sprite2D.flip_h = true
		elif dir.x == 1:
			$Sprite2D.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		$anim.play("hurt")
		await get_tree().create_timer(0.4).timeout
		#stop playing the hurt animation by setting taking_damage to false
		taking_damage = false
	#if dead, don't want to continue roaming the map
	elif dead and is_roaming:
		is_roaming = false
		$anim.play("death")
		await get_tree().create_timer(0.8).timeout
		handle_death()

#could just put queue free above under death animation. But do it this way in 
#case want to add something else to the death code		
func handle_death():
	self.queue_free()
			
func _on_direction_timer_timeout():
	# Will implement a choose function that will choose a time from array below
	$DirectionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_frog_chase:
		# if not chasing choose the left or right direction
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		print(dir)
		# whenever changing direction we want velcity equal to 0, otherwise it
		# will slide and that won't look right
		velocity.x = 0
	
func choose(array):
	#array.shuffle, to shuffle the items in the array up. 
	array.shuffle()
	# After shuffling, choose the value at the front of array
	return array.front()

func _on_frog_hit_box_area_entered(area):
	if area.name == "Sword":
		#take 1 damage from the sword at a time
		take_damage(1)
		
func take_damage(damage):
	if !dead:
		$anim.play("hurt")
		health -= damage
		taking_damage = true
		if health <= 0:
			health = 0
			dead = true
			
func _on_frog_deal_damage_area_body_entered(body):
	if !dead and body.name == "Player":
		$anim.play("attack")
		body.apply_damage(damage_to_deal)
		
		
		

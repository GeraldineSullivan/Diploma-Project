# FLYING ENEMIES

#followed tutorial by devWorm for flying enemy that follows player: 
# https://www.youtube.com/watch?v=SkDCubKXj10
# Changed some code to fit with this game. 
# Added constants for chase range, knockback, cooldown and attack range
# Original tutorial code had the bats chasing player always. 
# Successfully changed that

extends CharacterBody2D

const SPEED = 40
# added a chase range so that bat will only chase when in range
# otherwise will overwhelm the player if there are multiple bats
const CHASE_RANGE = 110
# This is for knocking the bat back when it attacks player
const KNOCKBACK_FORCE = 10.0
# cooldown to prevent bat continuously colliding with player
const COLLISION_COOLDOWN = 0.6
# attack range to play the attack animation when in range of player
const ATTACK_RANGE = 40
#attack cooldown, so bats won't continually attack player
const ATTACK_COOLDOWN = 1.0


var dir: Vector2
# Boolean to check if the bat is chasing the player
var is_bat_chase: bool
var is_roaming: bool
var player: CharacterBody2D
var health = 3
var dead = false
#set the bat taking damage to false intially
var taking_damage = false
#damage to cause on player
var damage_to_deal = 0.5
# trap_triggered: want bats in "Shardbats" group to chase player only when boss door trap is triggered
var trap_triggered = false
# Boolean to manage collision cooldown for bat colliding with player
var can_collide = true
# variable for the attack cooldown
var attack_on_cooldown = false
# added a signal so that boss door can be opened when bats are dead
signal bat_dead

# knockback duration for smoother pushback (separate from attack cooldown)
@export var KNOCKBACK_DURATION: float = 0.25 # knockback duration for smoother pushback (separate from attack cooldown)

@onready var bat_hurt = $Squeak # sound for when bat is hurt

# Not chasing the player at the start
func _ready():
	is_bat_chase = false
	$batDealDamageArea.connect("body_entered", Callable(self, "_on_bat_body_entered"))
	player = get_tree().root.get_node("Node2D/Player")  # Find the player node locally

func _process(delta):
	move(delta)
	handle_animation()
	# If the enemy is on the floor and dead, it will disappear in 1 second
	if is_on_floor() and dead:
		await get_tree().create_timer(0.2).timeout
		self.queue_free()

func move(delta):
	if !dead:
		is_roaming = true
		if player:
			# Calculate the distance to the player
			var distance_to_player = position.distance_to(player.position)
			if is_in_group("ShardBats"):
				# Check if the player is within the chase range and the trap is triggered before chasing
				if distance_to_player <= CHASE_RANGE and trap_triggered and not attack_on_cooldown:
					is_bat_chase = true
				else:
					is_bat_chase = false
			else:
				# Non-shardbats chase the player regardless of the trap state
				is_bat_chase = distance_to_player <= CHASE_RANGE and not attack_on_cooldown

			if !taking_damage and is_bat_chase:
				velocity = position.direction_to(player.position) * SPEED
				dir.x = abs(velocity.x) / velocity.x
			elif taking_damage:
				var knockback_dir = position.direction_to(player.position) * -50
				velocity = knockback_dir
			else:
				# Not following the player, move randomly
				velocity += dir * SPEED * delta
	elif dead:
		velocity.y += 15 * delta
		velocity.x = 0
	move_and_slide()

# Timer is set to Autostart in the inspector
func _on_timer_timeout():
	# Randomize the wait time between bat changing direction
	$Timer.wait_time = choose([0.5, 0.8, 1.2])
	# If the bat is not chasing the player, choose a random direction
	if !is_bat_chase:
		dir = choose([Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN])

func choose(array):
	array.shuffle()  # Shuffle the items in the array
	return array.front()  # Choose the value at the front of array

func handle_animation():
	var animated_sprite = $AnimatedSprite2D
	if !dead and !taking_damage:
		# Logic for attack range to use the "attack" animation
		var distance_to_player = position.distance_to(player.position)
		if distance_to_player <= ATTACK_RANGE:
			animated_sprite.play("attack")
		else:
			animated_sprite.play("fly")
			if dir.x == -1:
				animated_sprite.flip_h = true
			elif dir.x == 1:
				animated_sprite.flip_h = false
	elif !dead and taking_damage:
		animated_sprite.play("hurt")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		animated_sprite.play("death")
		# On death, set the bat's collision layer and mask to same as floor
		# so that it falls to floor and ignores bat boundary collision
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)

func _on_bat_hitbox_area_entered(area):
	if area.name == "Sword":
		take_damage(1)

func take_damage(damage):
	# Prevent the same bat from dying twice and messing up the count
	if !dead:
		bat_hurt.play()
		health -= damage
		taking_damage = true
		if health <= 0:
			health = 0
			dead = true
			emit_signal("bat_dead")

# Code for attacking the player
# Now will only deal damage if the bat is not dead
func _on_bat_body_entered(body):
	if !dead and body.name == "Player" and can_collide:
		body.apply_damage(damage_to_deal)
		await apply_knockback(body)
		await get_tree().create_timer(COLLISION_COOLDOWN).timeout
		can_collide = true

#func apply_knockback(body):
	## Apply the knockback force
	#var knockback_dir = (position - body.position).normalized()
	#velocity = knockback_dir * KNOCKBACK_FORCE
	## Apply a vertical adjustment to ensure the bat moves away instead of sticking to the player's head
	#if position.y < body.position.y:
		#velocity.y -= KNOCKBACK_FORCE / 2
	## Move the bat immediately to avoid overlap
	#position += knockback_dir * 30
	## Temporarily disable collision to help prevent the bat from sticking to the player
	#can_collide = false
	## Start the attack cooldown period
	#attack_on_cooldown = true
	#await get_tree().create_timer(ATTACK_COOLDOWN).timeout #cooldown timer
	#attack_on_cooldown = false
	#velocity = Vector2.ZERO  # Reset velocity to stop the knockback effect

# Knockback is now smoothed instead of jumpy
func apply_knockback(body):
# Apply the knockback force
	var knockback_dir = (position - body.position).normalized()
	velocity = knockback_dir * KNOCKBACK_FORCE
	# Apply a vertical adjustment to ensure the bat moves away instead of sticking to the player's head
	if position.y < body.position.y:
		velocity.y -= KNOCKBACK_FORCE / 2
	# Temporarily disable collision to help prevent the bat from sticking to the player
	can_collide = false
	attack_on_cooldown = true
	# Smoothly reduce velocity over time instead of instantly resetting
	var timer = KNOCKBACK_DURATION
	while timer > 0:
		await get_tree().process_frame
		timer -= get_process_delta_time()
		# move_toward gives a smooth ease-out effect for velocity
		velocity = velocity.move_toward(Vector2.ZERO, 200 * get_process_delta_time())
	# Reset states after knockback duration
	velocity = Vector2.ZERO
	attack_on_cooldown = false
	can_collide = true


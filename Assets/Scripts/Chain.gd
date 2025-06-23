# chain.gd
# This script controls a projectile chain that flies, collides, and hooks.
extends Node2D

# Signal to notify the player when the hook has successfully attached.
signal chain_hooked(hook_point, hook_body)

# `@onready` is the Godot 4 syntax for the old `onready`.
@onready var links: Sprite2D = $Links
@onready var tip_body: CharacterBody2D = $Tip # The tip should be a CharacterBody2D for collision

var direction := Vector2.ZERO
# The 'tip' variable now stores the global position of the tip_body.
var tip_position: Vector2

const SPEED = 3500  # Increased speed to work with delta-time movement

var flying = false
var hooked = false

# shoot() shoots the chain in a given direction
func shoot(dir: Vector2) -> void:
	# Don't shoot if already flying or hooked
	if flying or hooked:
		return
		
	direction = dir.normalized()
	flying = true
	hooked = false
	# Reset the tip's physical location to the chain's origin
	tip_body.global_position = self.global_position
	tip_position = self.global_position

# release() the chain
func release() -> void:
	flying = false
	hooked = false
	# When released, bring the tip back to the origin visually
	tip_position = self.global_position
	tip_body.global_position = self.global_position


func _process(_delta: float) -> void:
	self.visible = flying or hooked
	if not self.visible:
		return

	# Convert the global tip position to coordinates local to the chain's origin
	var tip_loc = to_local(tip_position)
	
	# `deg_to_rad` is the Godot 4 replacement for `deg2rad`
	var angle = Vector2.ZERO.angle_to_point(tip_loc) - deg_to_rad(90)
	
	links.rotation = angle
	tip_body.rotation = angle
	
	# Position the base of the links sprite at the tip
	links.position = tip_loc
	# Stretch the links sprite to cover the distance
	links.region_rect.size.y = tip_loc.length()


func _physics_process(delta: float) -> void:
	if flying:
		# Move the tip_body and check for collision
		var collision_result = tip_body.move_and_collide(direction * SPEED * delta)
		
		if collision_result:
			var collider = collision_result.get_collider()
			# Check if we hit a valid hookable object
			if collider and collider.is_in_group("Hookable"):
				hooked = true
				flying = false
				# Emit the signal with the collision point and the object we hit
				emit_signal("chain_hooked", tip_body.global_position, collider)
			else:
				# If we hit a non-hookable wall, just retract
				release()
	
	# Always update our tracking variable with the tip's latest global position
	tip_position = tip_body.global_position

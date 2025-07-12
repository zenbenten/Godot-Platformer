# The script now controls a CharacterBody2D.
extends CharacterBody2D

@export var item: ItemResource

# You can adjust these in the Inspector to change how the item falls and slides.
@export var gravity = 1000.0
# We no longer need initial_slide_speed, as the player script now controls it.
@export var friction = 500.0

# This flag prevents the item from being picked up instantly.
var can_be_picked_up = true

func _ready():
	if item:
		$Sprite2D.texture = item.pickup_texture
	# Connect the timer's signal to our handler function.
	$PickupDelayTimer.timeout.connect(_on_pickup_delay_timeout)

# The physics process function now handles gravity and movement.
func _physics_process(delta):
	# Apply gravity if the item is in the air.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Apply friction to the horizontal movement so it slides to a stop.
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	move_and_slide()

# This is the function called when the timer finishes.
func _on_pickup_delay_timeout():
	can_be_picked_up = true
	# Check if any players are already inside the area.
	for body in $Area2D.get_overlapping_bodies():
		_try_to_pickup(body)
		if not is_inside_tree():
			break

# All pickup logic is now in this single function.
func _try_to_pickup(body):
	if not can_be_picked_up or not body.has_method("add_item"):
		return
	
	body.add_item(item)
	queue_free()

# --- UPDATED FUNCTION ---
# This function is called by the player when the item is dropped.
# It now accepts a velocity vector to create the arc.
func initialize_drop(initial_velocity: Vector2):
	can_be_picked_up = false
	$PickupDelayTimer.start()

	# Set the body's velocity to the one calculated by the player.
	self.velocity = initial_velocity

# This is the function connected to your Area2D's body_entered signal.
func _on_area_2d_body_entered(body: Node2D) -> void:
	_try_to_pickup(body)

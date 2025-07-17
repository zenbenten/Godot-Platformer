# item_pickup.gd
extends CharacterBody2D

@export var item: ItemResource

@export var gravity = 1000.0
@export var friction = 500.0

var can_be_picked_up = true

func _ready():
	if item:
		$Sprite2D.texture = item.pickup_texture
	$PickupDelayTimer.timeout.connect(_on_pickup_delay_timeout)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	move_and_slide()

# --- THIS IS THE NEW, SIMPLIFIED LOGIC ---
func _try_to_pickup(body):
	# Check the guard conditions as before.
	if not can_be_picked_up or not body.has_method("handle_pickup"):
		return
	
	# Instead of handling logic here, just tell the player to handle it.
	# We pass ourself (the item pickup node) to the player.
	body.handle_pickup.call_deferred(self)
	# This node no longer destroys itself; the player will do it.


func _on_area_2d_body_entered(body: Node2D) -> void:
	_try_to_pickup(body)

func _on_pickup_delay_timeout():
	can_be_picked_up = true
	for body in $Area2D.get_overlapping_bodies():
		_try_to_pickup(body)
		if not is_instance_valid(self):
			break

func initialize_drop(initial_velocity: Vector2):
	can_be_picked_up = false
	$PickupDelayTimer.start()
	self.velocity = initial_velocity

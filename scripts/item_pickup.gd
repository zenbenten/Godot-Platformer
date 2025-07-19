# item_pickup.gd
extends CharacterBody2D

@export var item: ItemResource
@export var gravity = 1000.0
@export var friction = 500.0

func _ready():
	$Area2D.monitoring = true
	$PickupDelayTimer.timeout.connect(_on_pickup_delay_timeout)

func setup_dropped_item(item_resource_path: String, pos: Vector2, initial_velocity: Vector2):
	# DEBUG: (8) The new item pickup instance is configured
	print("(8) [ItemPickup ", name, "] Setup complete for item: ", item_resource_path.get_file())
	
	self.global_position = pos
	initialize_drop(initial_velocity)
	self.item = load(item_resource_path)
	if item:
		$Sprite2D.texture = item.pickup_texture

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	move_and_slide()

# This function is now simpler and more robust.
func _try_to_pickup(body):
	if not $Area2D.monitoring or not body.has_method("pickup_item"):
		return
	
	# "Give" our item data to the player and then disappear.
	body.pickup_item.call_deferred(self.item)
	queue_free.call_deferred()

func _on_area_2d_body_entered(body: Node2D) -> void:
	_try_to_pickup(body)

func _on_pickup_delay_timeout():
	$Area2D.monitoring = true

func initialize_drop(initial_velocity: Vector2):
	$Area2D.monitoring = false
	$PickupDelayTimer.start()
	self.velocity = initial_velocity

extends CharacterBody2D

@export var speed = 10.0
@export var jump_power = 10.0

var speed_multiplier = 30.0
var jump_multiplier = -30.0
var direction = 0

var has_grappling_hook: bool = true
var is_grappling: bool = false

func _physics_process(delta: float) -> void:
	if not is_grappling:
		handle_movement(delta)

	handle_grappling(delta)

func handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power * jump_multiplier

	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed * speed_multiplier)

	move_and_slide()

func handle_grappling(delta: float) -> void:
	if not has_grappling_hook:
		return

	if Input.is_action_just_pressed("item_use"):
		for g in get_tree().get_nodes_in_group("grappling-hook-system"):
			var success = g.attach_player(self)
			if success == 0:
				is_grappling = true
				break
	elif Input.is_action_just_released("item_use"):
		for g in get_tree().get_nodes_in_group("grappling-hook-system"):
			var success = g.detach_player(self)
			if success == 0:
				is_grappling = false
				break

	# Lock player rotation while swinging
	global_rotation = 0


# Optional: Call this from an Area2D or pickup trigger
func give_grappling_hook():
	has_grappling_hook = true

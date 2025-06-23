# Move.gd
extends State
class_name MoveState

# We need a reference to the player to access things like velocity and move_and_slide()
# 'owner' is a built-in property that refers to the scene root (our Player node).
@onready var player = owner

func process_physics(_delta: float):
	# Handle horizontal movement
	var move_input = Input.get_axis("move_left", "move_right")
	player.velocity.x = move_input * player.speed
	
	# Handle gravity
	if not player.is_on_floor():
		player.velocity.y += player.gravity * _delta
	
	# Handle jumping
	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		player.velocity.y = -player.jump_force
	
	# --- TRANSITION ---
	# Check if we should transition to the Grapple state.
	if Input.is_action_just_pressed("item_use"):
		var hook_data = player.find_closest_hook_point()
		if hook_data:
			# 1. Store the data on the player node.
			player.grapple_hook_data = hook_data
			# 2. Simply request the state change.
			state_machine.change_state("Grapple")

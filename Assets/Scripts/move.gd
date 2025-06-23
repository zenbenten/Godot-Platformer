# Move.gd (Corrected and Cleaned)
extends State
class_name MoveState

# It's good practice to get the player reference once.
@onready var player = get_owner()

func enter():
	# When we enter the Move state (i.e., land on the ground),
	# we should refresh our ability to air-jump.
	player.can_jump = true

func process_physics(_delta: float):
	# --- STATE TRANSITION ---
	# First, check if we should leave this state. If we fall off a ledge,
	# we are no longer in the "Move" state.
	if not player.is_on_floor():
		state_machine.change_state("Air")
		return # Stop processing here to avoid running code for the wrong state

	# --- HANDLE MOVEMENT ---
	# Get player input for walking.
	var move_input = Input.get_axis("move_left", "move_right")
	player.velocity.x = move_input * player.move_speed
	
	# Apply gravity to keep the player stuck to the floor.
	player.velocity.y += player.gravity_amount * _delta
	
	# Handle jumping.
	if Input.is_action_just_pressed("jump"):
		player.velocity.y = -player.jump_force
		# Jumping immediately puts us in the air, so we change state.
		state_machine.change_state("Air")
		return

	# --- APPLY FRICTION ---
	# Apply ground friction to slow down when there's no input.
	player.velocity.x = lerp(player.velocity.x, 0.0, player.friction_ground)

# The logic for firing the hook has been removed from this script,
# because it's now handled entirely by Player.gd's _input() function.

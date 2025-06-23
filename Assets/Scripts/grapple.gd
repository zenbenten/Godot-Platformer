# Grapple.gd
extends State
class_name GrappleState

@onready var player = owner

# DELETED: We are removing the old setup_hook() function entirely.

# The 'enter' function is the perfect place for all setup logic.
# It is called by the state machine exactly when this state becomes active.
func enter():
	# Check if the hook data is valid before using it.
	if player.grapple_hook_data.is_empty():
		# If for some reason the data is missing, abort and go back to Move state.
		# This is a defensive check to prevent crashes.
		state_machine.change_state("Move")
		return

	# Set up the grapple using the data stored on the player.
	player.hooked = true
	player.pinjoint.global_position = player.grapple_hook_data["point"]
	player.pinjoint.node_b = player.grapple_hook_data["body"].get_path()
	
	# It's good practice to clear the data after using it.
	player.grapple_hook_data.clear()

func exit():
	# This cleanup logic is still correct.
	player.hooked = false
	if player.pinjoint:
		player.pinjoint.node_b = NodePath("")

func process_physics(_delta: float):
	# This physics logic is still correct.
	var swing_influence = Input.get_axis("move_left", "move_right") * player.speed * 0.5
	player.velocity.x += swing_influence * _delta
	
	# This transition logic is still correct.
	if Input.is_action_just_released("item_use"):
		state_machine.change_state("Move")

# IdleState.gd
# Handles logic for when the player is standing still.

extends State

# Exports for tweaking physics from the Inspector.
@export var ground_friction = 0.90

func enter(msg: Dictionary = {}):
	# This is a good place to trigger an "idle" animation.
	# For example: state_machine.player.animation_player.play("Idle")
	pass

func process_physics(_delta: float):
	var player = state_machine.player

	# Apply gravity. Even when idle, gravity should be active
	# to ensure the player stays grounded on slopes or moving platforms.
	player.velocity.y += 60 # Using your established gravity value

	# Apply friction to slow the player down to a stop.
	player.velocity.x = lerp(player.velocity.x, 0.0, ground_friction)

	# The move_and_slide() function is essential to apply physics and detect collisions.
	player.move_and_slide()

	# --- STATE TRANSITIONS ---

	# 1. Transition to Move if there's horizontal input.
	var walk_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if not is_zero_approx(walk_input):
		state_machine.transition_to("Move")
		return # Important to return after a transition

	# 2. Transition to Jump if the jump action is pressed.
	if Input.is_action_just_pressed("jump"):
		# We send a message so the Jump state knows to apply the jump force.
		state_machine.transition_to("Jump", {"is_jump": true})
		return

	# 3. Transition to Swing if the item is used.
	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			state_machine.transition_to("Swing")
			return
			
	# 4. Transition to Jump/Fall if the player walks off a ledge.
	if not player.is_on_floor():
		# We don't send a message, so the Jump state knows this is a fall, not a jump.
		state_machine.transition_to("Jump")
		return

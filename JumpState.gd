# JumpState.gd
# Handles all airborne logic, including jumping and falling.

extends State

# Exports for tweaking physics from the Inspector.
@export var air_speed = 400
@export var air_friction = 0.95

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	
	# This is the key logic: check if we entered this state from a jump action.
	# The "is_jump" key is sent from the Idle or Move state.
	if msg.has("is_jump") and msg.is_jump == true:
		# Apply the jump force. The JUMP_FORCE should be defined in your Player.gd script.
		player.velocity.y = -player.JUMP_FORCE
		
		# This is a good place to play a "jump" animation.
		# For example: state_machine.player.animation_player.play("Jump")
	else:
		# If no "is_jump" message, we are falling.
		# Play a "fall" animation here.
		# For example: state_machine.player.animation_player.play("Fall")
		pass

func process_physics(_delta: float):
	var player = state_machine.player

	# Apply gravity.
	player.velocity.y += 60 # Using your established gravity value

	# Handle air control.
	var walk_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	player.velocity.x += walk_input * air_speed
	
	# Apply air friction to prevent infinite acceleration.
	player.velocity.x *= air_friction

	player.move_and_slide()

	# --- STATE TRANSITIONS ---
	
	# 1. Transition to Idle or Move when we land on the floor.
	if player.is_on_floor():
		if is_zero_approx(player.velocity.x):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Move")
		return

	# 2. Transition to Swing if the item is used mid-air.
	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			state_machine.transition_to("Swing")
			return

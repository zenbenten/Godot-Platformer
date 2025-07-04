# IdleState.gd
# Correctly implements the jump buffer timer check upon entering the state.

extends State

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	print("Player " + str(player.name) + " entering IDLE State.")
	
	# --- CORRECTED JUMP BUFFER CHECK ---
	# Check if the time since the jump was buffered is within the allowed window.
	var time_since_buffer = (Time.get_ticks_msec() / 1000.0) - player.time_jump_was_buffered
	if time_since_buffer < player.jump_buffer:
		player.jump_to_consume = true
		state_machine.transition_to("Jump")
		return

func process_physics(delta: float):
	if not is_multiplayer_authority():
		return
	var player = state_machine.player
	
	print("Player " + str(player.name) + " in " + self.name + " state. is_on_floor(): " + str(player.is_on_floor()))
	# Apply deceleration to smoothly come to a stop.
	player.velocity.x = move_toward(player.velocity.x, 0, player.ground_deceleration * delta)
	
	# Apply a small grounding force to stick to slopes.
	player.velocity.y = player.grounding_force

	player.move_and_slide()
	
	# If jump is pressed while on the ground, set the flag and transition.
	if Input.is_action_just_pressed("jump"):
		player.jump_to_consume = true
		state_machine.transition_to("Jump")
		return

	# Transition to Move if there's horizontal input.
	var walk_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if not is_zero_approx(walk_input):
		state_machine.transition_to("Move")
		return
		
	# Transition to Jump/Fall if we walk off a ledge.
	if not player.is_on_floor():
		player.time_left_ground = Time.get_ticks_msec() / 1000.0
		state_machine.transition_to("Jump")
		return
		
	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
			var vertical_input = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
			var aim_direction = Vector2(horizontal_input, vertical_input)
			if aim_direction == Vector2.ZERO:
				aim_direction = Vector2(player.facing_direction, 0)
			state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})
			return

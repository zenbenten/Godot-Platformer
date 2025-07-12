# MoveState.gd
# Correctly implements the jump buffer timer check upon entering the state.
extends State

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	print("Player " + str(player.name) + " entering MOVE State.")
	
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
	
	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)

	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.acceleration * delta)
	player.velocity.y = player.grounding_force
	player.move_and_slide()
	
	# If jump is pressed while on the ground, set the flag and transition.
	if Input.is_action_just_pressed("jump"):
		player.jump_to_consume = true
		state_machine.transition_to("Jump")
		return
	
	if Input.is_action_just_pressed("item_use"):
		# Check if the player is holding an item to use or drop.
		if player.current_item:
			# Capture all directional input from the player.
			var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
			var vertical_input = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
			var input_vector = Vector2(horizontal_input, vertical_input)

			# CONDITION: If the player is ONLY holding "down", it's a drop command.
			if input_vector == Vector2.DOWN:
				player.drop_item()
				return
			
			# Otherwise, it's a "use item" command.
			if player.has_ability("Grappling Hook"):
				var aim_direction = input_vector
				# If no direction is held, fire straight ahead.
				if aim_direction == Vector2.ZERO:
					aim_direction = Vector2(player.facing_direction, 0)
				
				state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})
				return
		
	if is_zero_approx(direction_input):
		state_machine.transition_to("Idle")
		return

	if not player.is_on_floor():
		player.time_left_ground = Time.get_ticks_msec() / 1000.0
		state_machine.transition_to("Jump")
		return

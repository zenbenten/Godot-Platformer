# JumpState.gd
# Updated to handle shooting diagonally down, straight down, up, angled, and horizontally.

extends State

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	if msg.has("is_jump"):
		player.velocity.y = player.jump_force
		player.current_jump_hold_time = player.jump_hold_time

func process_physics(delta: float):
	var player = state_machine.player
	
	if Input.is_action_pressed("jump") and player.current_jump_hold_time > 0:
		player.velocity.y = player.jump_force
	else:
		player.current_jump_hold_time = 0
		
	player.current_jump_hold_time -= delta

	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)

	player.velocity.x = move_toward(player.velocity.x, player.max_run_speed * direction_input, player.run_accel * delta)
	player.velocity.y = move_toward(player.velocity.y, player.max_fall_speed, player.gravity * delta)
	player.move_and_slide()
	
	# --- STATE TRANSITIONS ---

	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			var aim_direction = Vector2.ZERO
			
			# Check for vertical aim input, prioritizing down over up.
			if Input.is_action_pressed("look_down"):
				if is_zero_approx(direction_input):
					# If only looking down, aim straight down
					aim_direction = Vector2.DOWN
				else:
					# If looking down and moving left/right, aim diagonally down
					aim_direction = Vector2(player.facing_direction, 1)
			elif Input.is_action_pressed("look_up"):
				if is_zero_approx(direction_input):
					# If only looking up, aim straight up
					aim_direction = Vector2.UP
				else:
					# If looking up and moving left/right, aim diagonally up
					aim_direction = Vector2(player.facing_direction, -1)
			else:
				# If no vertical input, aim straight horizontally
				aim_direction = Vector2(player.facing_direction, 0)
				
			state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})
			return
			
	if player.is_on_floor():
		if is_zero_approx(direction_input):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Move")
		return

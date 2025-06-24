# MoveState.gd
# Updated to handle angled grappling shots.

extends State

func process_physics(delta: float):
	var player = state_machine.player
	
	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)

	player.velocity.x = move_toward(player.velocity.x, player.max_run_speed * direction_input, player.run_accel * delta)
	player.velocity.y = move_toward(player.velocity.y, player.max_fall_speed, player.gravity * delta)
	player.move_and_slide()
	
	# --- STATE TRANSITIONS ---

	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			var aim_direction = Vector2(player.facing_direction, 0)
			if Input.is_action_pressed("look_up"):
				aim_direction.y = -1 # Upward angle
			
			state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})
			return
			
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {"is_jump": true})
		return
		
	if not player.is_on_floor():
		state_machine.transition_to("Jump")
		return
		
	if is_zero_approx(direction_input):
		state_machine.transition_to("Idle")
		return

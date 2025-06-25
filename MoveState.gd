# MoveState.gd
# Updated with correct 8-way aiming logic.

extends State

func enter(msg: Dictionary = {}):
	print("Entered Move State")

func process_physics(delta: float):
	var player = state_machine.player
	
	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)

	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.acceleration * delta)
	player.velocity.y = player.grounding_force
	player.move_and_slide()
	
	if Input.is_action_just_pressed("jump"):
		player.jump_to_consume = true
	
	# --- Corrected Aiming Logic ---
	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			print("MoveState: Player has hook. Calculating aim...")

			var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
			var vertical_input = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
			
			var aim_direction = Vector2(horizontal_input, vertical_input)
			
			if aim_direction == Vector2.ZERO:
				aim_direction = Vector2(player.facing_direction, 0)

			print("MoveState: Calculated Aim Direction: ", aim_direction.normalized())
			state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})
			return
	
	if player.jump_to_consume:
		state_machine.transition_to("Jump")
		return
		
	if is_zero_approx(direction_input):
		state_machine.transition_to("Idle")
		return

	if not player.is_on_floor():
		player.time_left_ground = Time.get_ticks_msec() / 1000.0
		state_machine.transition_to("Jump")
		return

func exit():
	print("Exiting Move State")

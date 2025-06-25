# IdleState.gd
# Updated with correct 8-way aiming logic.

extends State

func enter(msg: Dictionary = {}):
	print("Entered Idle State")
	pass

func process_physics(delta: float):
	var player = state_machine.player
	
	player.velocity.x = move_toward(player.velocity.x, 0, player.ground_deceleration * delta)
	player.velocity.y = player.grounding_force
	player.move_and_slide()

	if Input.is_action_just_pressed("jump"):
		player.jump_to_consume = true
	
	if player.jump_to_consume:
		state_machine.transition_to("Jump")
		return

	var walk_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if not is_zero_approx(walk_input):
		state_machine.transition_to("Move")
		return
		
	if not player.is_on_floor():
		player.time_left_ground = Time.get_ticks_msec() / 1000.0
		state_machine.transition_to("Jump")
		return

	# --- Corrected Aiming Logic ---
	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			print("IdleState: Player has hook. Calculating aim...")
			
			# Get both horizontal and vertical inputs
			var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
			var vertical_input = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
			
			# Create a direction vector from the inputs
			var aim_direction = Vector2(horizontal_input, vertical_input)
			
			# If there's no input at all, default to the player's facing direction
			if aim_direction == Vector2.ZERO:
				aim_direction = Vector2(player.facing_direction, 0)

			print("IdleState: Calculated Aim Direction: ", aim_direction.normalized())
			state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})
			return

func exit():
	print("Exiting Idle State")

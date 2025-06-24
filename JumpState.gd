extends State

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	if msg.has("is_jump"):
		player.velocity.y = player.jump_force
		# Start the timer for holding the jump button
		player.current_jump_hold_time = player.jump_hold_time

func process_physics(delta: float):
	var player = state_machine.player
	
	# --- NEW JUMP LOGIC ---
	# Check if the player is still holding the jump button and the hold timer is active
	if Input.is_action_pressed("jump") and player.current_jump_hold_time > 0:
		# While holding, maintain the upward jump force
		player.velocity.y = player.jump_force
	else:
		# If they let go or the time runs out, stop the hold
		player.current_jump_hold_time = 0
		
	# Decrease the hold timer
	player.current_jump_hold_time -= delta

	# Get horizontal input for air control
	var direction = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
	
	# Apply air control (you can create separate `air_accel` vars for this)
	player.velocity.x = move_toward(player.velocity.x, player.max_run_speed * direction, player.run_accel * delta)
	
	# Apply gravity towards max fall speed
	player.velocity.y = move_toward(player.velocity.y, player.max_fall_speed, player.gravity * delta)
	
	player.move_and_slide()
	
	# --- State Transitions ---
	if player.is_on_floor():
		state_machine.transition_to("Idle") # Or Move, depending on input
		
	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			state_machine.transition_to("Swing")
			return

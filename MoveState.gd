extends State

func process_physics(delta: float):
	var player = state_machine.player
	
	# Get horizontal input direction
	var direction = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
	
	# --- NEW MOVEMENT LOGIC ---
	# Apply acceleration using move_toward
	player.velocity.x = move_toward(player.velocity.x, player.max_run_speed * direction, player.run_accel * delta)
	
	# Apply gravity (even on the ground to handle slopes)
	player.velocity.y = move_toward(player.velocity.y, player.max_fall_speed, player.gravity * delta)
	
	player.move_and_slide()
	
	# --- State Transitions ---
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {"is_jump": true})
		return
		
	if not player.is_on_floor():
		state_machine.transition_to("Jump") # Fall
		return
		
	# Transition to Idle if not moving
	if is_zero_approx(direction):
		state_machine.transition_to("Idle")
		return
	
	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			state_machine.transition_to("Swing")
			return
		#ANIMATION#
	#if direction > 0:
	#player.get_node("Sprite2D").flip_h = false
#elif direction < 0:
	#player.get_node("Sprite2D").flip_h = true
#// player.animation_player.play("Run")

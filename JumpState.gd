# JumpState.gd
# Updated with correct 8-way aiming logic.

extends State

var ended_jump_early = false

func enter(msg: Dictionary = {}):
	print("Entered Jump State")
	var player = state_machine.player
	
	var time_in_air = (Time.get_ticks_msec() / 1000.0) - player.time_left_ground
	var can_use_coyote = time_in_air < player.coyote_time
	
	if player.jump_to_consume and (player.is_on_floor() or can_use_coyote):
		execute_jump()
	
	player.jump_to_consume = false

func execute_jump():
	var player = state_machine.player
	player.jump_to_consume = false
	ended_jump_early = false
	player.velocity.y = player.jump_velocity

func process_physics(delta: float):
	var player = state_machine.player

	if not Input.is_action_pressed("jump") and player.velocity.y < 0:
		ended_jump_early = true

	var gravity_multiplier = 1.0
	if ended_jump_early:
		gravity_multiplier = player.jump_end_early_gravity_modifier
	elif player.velocity.y > 0:
		gravity_multiplier = player.fall_gravity_multiplier
		
	player.velocity.y += player.gravity * gravity_multiplier * delta
	
	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)
	
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.air_deceleration * delta)
	player.move_and_slide()

	if Input.is_action_just_pressed("jump"):
		player.jump_to_consume = true

	# --- Corrected Aiming Logic ---
	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			print("JumpState: Player has hook. Calculating aim...")

			var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
			var vertical_input = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
			
			var aim_direction = Vector2(horizontal_input, vertical_input)
			
			if aim_direction == Vector2.ZERO:
				aim_direction = Vector2(player.facing_direction, 0)

			print("JumpState: Calculated Aim Direction: ", aim_direction.normalized())
			state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})
			return

	if player.is_on_floor():
		if player.jump_to_consume:
			state_machine.transition_to("Jump")
		else:
			state_machine.transition_to("Idle")
		return

func exit():
	print("Exiting Jump State")

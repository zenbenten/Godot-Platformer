# JumpState.gd
# Correctly implements the jump buffer timer.

extends State

var ended_jump_early = false

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	
	# MODIFIED PRINT STATEMENT
	print("Player " + str(player.name) + " entering JUMP State.")
	# This state is entered when the player jumps.
	# The ground states will set the jump_to_consume flag if the jump is valid.
	if player.jump_to_consume:
		execute_jump()
	else:
		# If we enter this state by falling off a ledge, the jump has effectively "ended".
		ended_jump_early = true

func execute_jump():
	var player = state_machine.player
	player.jump_to_consume = false
	ended_jump_early = false
	player.velocity.y = player.jump_velocity

func process_physics(delta: float):
	if not is_multiplayer_authority():
		return
	var player = state_machine.player
	
	print("Player " + str(player.name) + " in " + self.name + " state. is_on_floor(): " + str(player.is_on_floor()))
	# --- Variable Jump Height Logic ---
	# If the jump button is released while moving up, cut the jump short.
	if not Input.is_action_pressed("jump") and player.velocity.y < 0:
		ended_jump_early = true
		
	# --- Gravity Application ---
	var gravity_multiplier = 1.0
	if ended_jump_early:
		gravity_multiplier = player.jump_end_early_gravity_modifier
	elif player.velocity.y > 0: # Apply stronger gravity when falling
		gravity_multiplier = player.fall_gravity_multiplier
		
	player.velocity.y += player.gravity * gravity_multiplier * delta
	
	# --- Horizontal Air Control ---
	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.air_deceleration * delta)
	
	player.move_and_slide()

	# --- CORRECTED JUMP BUFFER LOGIC ---
	# When jump is pressed while in the air, we don't set a boolean anymore.
	# We simply store the exact time the button was pressed.
	if Input.is_action_just_pressed("jump"):
		player.time_jump_was_buffered = Time.get_ticks_msec() / 1000.0

	# --- State Transitions ---
	# When we land, transition to a ground state. The ground state will be
	# responsible for checking the buffer timestamp and deciding to jump again.
	if player.is_on_floor():
		state_machine.transition_to("Idle")
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

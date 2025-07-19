# JumpState.gd
extends State

var ended_jump_early = false

func enter(_msg: Dictionary = {}):
	var player = state_machine.player
	print("Player " + str(player.name) + " entering JUMP State.")

	var time_since_left_ground = (Time.get_ticks_msec() / 1000.0) - player.time_left_ground
	
	if time_since_left_ground < player.coyote_time and player.client_wants_to_jump:
		player.jump_to_consume = true

	if player.jump_to_consume:
		execute_jump()
	else:
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
	
	if not player.client_is_holding_jump and player.velocity.y < 0:
		ended_jump_early = true
		
	var gravity_multiplier = 1.0
	if ended_jump_early:
		gravity_multiplier = player.jump_end_early_gravity_modifier
	elif player.velocity.y > 0:
		gravity_multiplier = player.fall_gravity_multiplier
		
	player.velocity.y += player.gravity * gravity_multiplier * delta
	
	var direction_input = player.client_input_direction
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.air_deceleration * delta)
	
	player.move_and_slide()

	if player.client_wants_to_jump:
		player.time_jump_was_buffered = Time.get_ticks_msec() / 1000.0
		player.client_wants_to_jump = false

	if player.is_on_floor():
		state_machine.transition_to("Idle")
		return

func on_item_input(press: bool, _release: bool, aim_vector: Vector2):
	if press:
		var player = state_machine.player
		# DEBUG: (3) The current state processes the event
		print("(3) [", self.name, " for Player ", player.name, "] Processing item input. Drop command: ", (aim_vector == Vector2.DOWN))
		
		if player.current_item:
			if aim_vector == Vector2.DOWN:
				player.manual_drop_item()
				return
			
			if player.has_ability("Grappling Hook"):
				var aim_direction = aim_vector
				if aim_direction == Vector2.ZERO:
					aim_direction = Vector2(player.facing_direction, 0)
				state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})

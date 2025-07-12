# MoveState.gd
extends State

func enter(_msg: Dictionary = {}):
	var player = state_machine.player
	print("Player " + str(player.name) + " entering MOVE State.")
	
	var time_since_buffer = (Time.get_ticks_msec() / 1000.0) - player.time_jump_was_buffered
	if time_since_buffer < player.jump_buffer:
		player.jump_to_consume = true
		state_machine.transition_to("Jump")
		return

func process_physics(delta: float):
	if not is_multiplayer_authority():
		return
	var player = state_machine.player
	
	var direction_input = player.client_input_direction
	
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)

	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.acceleration * delta)
	player.velocity.y = player.grounding_force
	player.move_and_slide()
	
	if player.client_wants_to_jump:
		player.jump_to_consume = true
		state_machine.transition_to("Jump")
		player.client_wants_to_jump = false
		return
		
	if is_zero_approx(direction_input):
		state_machine.transition_to("Idle")
		return

	if not player.is_on_floor():
		player.time_left_ground = Time.get_ticks_msec() / 1000.0
		state_machine.transition_to("Jump")
		return

func on_item_input(press: bool, release: bool, aim_vector: Vector2):
	# This state only cares about the initial press of the button.
	if press:
		var player = state_machine.player
		if player.current_item and player.has_ability("Grappling Hook"):
			if aim_vector == Vector2.DOWN:
				player.drop_item()
				return
			
			var aim_direction = aim_vector
			if aim_direction == Vector2.ZERO:
				aim_direction = Vector2(player.facing_direction, 0)
				
			state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})

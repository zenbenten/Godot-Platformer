# This is the full script for IdleState.gd.
# The changes are identical for MoveState.gd and JumpState.gd.
# Replace their content accordingly.

# IdleState.gd
extends State

func enter(_msg: Dictionary = {}):
	var player = state_machine.player
	print("Player " + str(player.name) + " entering IDLE State.")
	
	var time_since_buffer = (Time.get_ticks_msec() / 1000.0) - player.time_jump_was_buffered
	if time_since_buffer < player.jump_buffer:
		player.jump_to_consume = true
		state_machine.transition_to("Jump")
		return

func process_physics(delta: float):
	if not is_multiplayer_authority():
		return
	var player = state_machine.player
	
	player.velocity.x = move_toward(player.velocity.x, 0, player.ground_deceleration * delta)
	player.velocity.y = player.grounding_force
	player.move_and_slide()
	
	if player.client_wants_to_jump:
		player.jump_to_consume = true
		state_machine.transition_to("Jump")
		player.client_wants_to_jump = false
		return

	if not is_zero_approx(player.client_input_direction):
		state_machine.transition_to("Move")
		return
		
	if not player.is_on_floor():
		player.time_left_ground = Time.get_ticks_msec() / 1000.0
		state_machine.transition_to("Jump")
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

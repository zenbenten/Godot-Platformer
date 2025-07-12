# SwingState.gd
extends State

# This reference will be set by the host to the pre-existing node.
var hook_ability

func enter(_msg: Dictionary = {}) -> void:
	var player = state_machine.player
	print("Player " + str(player.name) + " entering SWING State.")

	# Get a direct reference to the pre-existing Chain node.
	hook_ability = player.get_node("Chain")
	var aim_direction = player.client_item_aim_vector
	if aim_direction == Vector2.ZERO:
		aim_direction = Vector2(player.facing_direction, 0)

	if hook_ability:
		# Activate the node and then call the shoot RPC.
		hook_ability.process_mode = Node.PROCESS_MODE_INHERIT
		hook_ability.rpc("shoot", aim_direction)
	else:
		state_machine.transition_to("Jump")


func process_physics(delta: float):
	if not is_multiplayer_authority():
		return
	var player = state_machine.player

	if not is_instance_valid(hook_ability) or (not hook_ability.flying and not hook_ability.hooked):
		state_machine.transition_to("Jump")
		return

	if hook_ability.hooked:
		var chain_velocity = (hook_ability.tip - player.global_position).normalized() * 30
		player.velocity += chain_velocity
		player.velocity.y += player.gravity * player.swing_gravity_multiplier * delta
	else:
		var gravity_multiplier = 1.0
		if player.velocity.y > 0:
			gravity_multiplier = player.fall_gravity_multiplier
		player.velocity.y += player.gravity * gravity_multiplier * delta

	var direction_input = player.client_input_direction
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.air_deceleration * delta)
	
	player.move_and_slide()

	if player.client_wants_to_use_item:
		if is_instance_valid(hook_ability):
			var input_vector = player.client_item_aim_vector
			if input_vector == Vector2.DOWN:
				hook_ability.rpc("release")
			elif is_instance_valid(hook_ability):
				hook_ability.rpc("release")
		player.client_wants_to_use_item = false

func exit():
	if is_instance_valid(hook_ability):
		hook_ability.rpc("release")

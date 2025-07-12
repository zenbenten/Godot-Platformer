# SwingState.gd
extends State

var hook_ability

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	print("Player " + str(player.name) + " entering SWING State.")

	hook_ability = player.get_node("Chain")
	var aim_direction = msg.get("aim_direction", Vector2(player.facing_direction, 0))

	if hook_ability:
		hook_ability.process_mode = Node.PROCESS_MODE_INHERIT
		hook_ability.shoot(aim_direction)
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

func exit():
	if is_instance_valid(hook_ability):
		hook_ability.rpc("release")

func on_item_input(press: bool, release: bool, _aim_vector: Vector2):
	# This state only cares about the release of the button.
	if release:
		if is_instance_valid(hook_ability):
			hook_ability.rpc("release")

# SwingState.gd
# This state handles all logic while the grappling hook is active.

extends State

var hook_ability

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	hook_ability = player.find_child("Chain", true, false)

	if hook_ability:
		hook_ability.set_process_mode(Node.PROCESS_MODE_INHERIT)
		
		var aim_direction = msg.get("aim_direction", Vector2(player.facing_direction, 0))
		hook_ability.shoot(aim_direction)
	else:
		state_machine.transition_to("Jump")

func process_physics(delta: float):
	var player = state_machine.player

	if not hook_ability or (not hook_ability.flying and not hook_ability.hooked):
		state_machine.transition_to("Jump")
		return

	# --- NEW LOGIC: Separate physics for Flying vs. Hooked ---
	if hook_ability.hooked:
		# --- PHASE 2: HOOKED ---
		# Apply the pulling force from the chain.
		var chain_velocity = (hook_ability.tip - player.global_position).normalized() * 30
		player.velocity += chain_velocity
		
		# Apply the special, floaty swinging gravity.
		player.velocity.y += player.gravity * player.swing_gravity_multiplier * delta
	else:
		# --- PHASE 1: HOOK IS FLYING ---
		# While the hook is in the air, use the same gravity as the JumpState.
		# This prevents the player from floating.
		var gravity_multiplier = 1.0
		if player.velocity.y > 0: # We are falling
			gravity_multiplier = player.fall_gravity_multiplier
		player.velocity.y += player.gravity * gravity_multiplier * delta

	# --- Universal Air Control ---
	# Apply horizontal movement and air deceleration at all times during this state.
	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.air_deceleration * delta)
	
	player.move_and_slide()

	if Input.is_action_just_released("item_use"):
		hook_ability.release()

func exit():
	if hook_ability:
		hook_ability.release()
		hook_ability.set_process_mode(Node.PROCESS_MODE_DISABLED)

# SwingState.gd
# MODIFIED to revert to normal gravity after a 1-second timer on a side hook.
extends State

var hook_ability
var side_hook_timer: Timer
var use_normal_gravity: bool = false

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	print("Player " + str(player.name) + " entering SWING State.")
	
	# Reset state variables
	use_normal_gravity = false
	hook_ability = player.find_child("Chain", true, false)

	# Create and configure the timer for this state instance
	side_hook_timer = Timer.new()
	side_hook_timer.wait_time = 1.0
	side_hook_timer.one_shot = true
	add_child(side_hook_timer) # Add to scene tree to be processed
	side_hook_timer.timeout.connect(_on_side_hook_timer_timeout)

	if hook_ability:
		hook_ability.set_process_mode(Node.PROCESS_MODE_INHERIT)
		var aim_direction = msg.get("aim_direction", Vector2(player.facing_direction, 0))
		hook_ability.shoot(aim_direction)
	else:
		state_machine.transition_to("Jump")

func exit():
	if hook_ability:
		hook_ability.release()
		hook_ability.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
	# Clean up the timer when exiting the state
	if side_hook_timer:
		side_hook_timer.stop()
		side_hook_timer.queue_free()

func _on_side_hook_timer_timeout():
	# When the timer finishes, flag that we should use normal gravity
	use_normal_gravity = true

func process_physics(delta: float):
	if not is_multiplayer_authority():
		return
	var player = state_machine.player

	if not hook_ability or (not hook_ability.flying and not hook_ability.hooked):
		state_machine.transition_to("Jump")
		return

	if hook_ability.hooked:
		# --- PHASE 2: HOOKED ---
		
		# Check for a side hook only on the first frame of connection
		# This condition is only true before the timer has started or finished
		if side_hook_timer.is_stopped() and not use_normal_gravity:
			var direction_to_hook = (hook_ability.tip - player.global_position).normalized()
			# If hook is more horizontal than vertical, it's a side hook
			if abs(direction_to_hook.x) > abs(direction_to_hook.y):
				side_hook_timer.start()

		# Apply the pulling force from the chain
		var chain_velocity = (hook_ability.tip - player.global_position).normalized() * 30
		player.velocity += chain_velocity
		
		# Apply gravity conditionally
		if use_normal_gravity:
			player.velocity.y += player.gravity * player.fall_gravity_multiplier * delta
		else:
			player.velocity.y += player.gravity * player.swing_gravity_multiplier * delta
	else:
		# --- PHASE 1: HOOK IS FLYING ---
		var gravity_multiplier = 1.0
		if player.velocity.y > 0: # We are falling
			gravity_multiplier = player.fall_gravity_multiplier
		player.velocity.y += player.gravity * gravity_multiplier * delta

	# --- Universal Air Control ---
	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if not is_zero_approx(direction_input):
		player.facing_direction = sign(direction_input)
	player.velocity.x = move_toward(player.velocity.x, player.max_speed * direction_input, player.air_deceleration * delta)
	
	player.move_and_slide()

	if Input.is_action_just_released("item_use"):
		hook_ability.release()

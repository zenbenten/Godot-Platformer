# SwingState.gd
# This state handles all logic while the grappling hook is active.

extends State

var hook_ability

func enter(msg: Dictionary = {}):
	print("Attempting to enter SwingState...")
	var player = state_machine.player
	hook_ability = player.find_child("GrapplingHookAbility", true, false)

	if hook_ability:
		print("SwingState: Found hook ability node.")
		hook_ability.set_process_mode(Node.PROCESS_MODE_INHERIT)
		
		var aim_direction = msg.get("aim_direction", Vector2(player.facing_direction, 0))
		print("SwingState: Firing hook in direction: ", aim_direction)
		hook_ability.shoot(aim_direction)
	else:
		print("SwingState ERROR: Could not find hook ability node! Aborting transition.")
		state_machine.transition_to("Jump")

func process_physics(delta: float):
	var player = state_machine.player

	if not hook_ability:
		state_machine.transition_to("Jump")
		return

	if not hook_ability.flying and not hook_ability.hooked:
		print("SwingState: Hook is no longer active. Transitioning to Jump.")
		state_machine.transition_to("Jump")
		return

	if hook_ability.hooked:
		var chain_velocity = (hook_ability.tip - player.global_position).normalized() * 30
		player.velocity += chain_velocity
	
	player.velocity.y += player.gravity * player.swing_gravity_multiplier * delta
	player.move_and_slide()

	if Input.is_action_just_released("item_use"):
		print("SwingState: 'item_use' released. Releasing hook.")
		hook_ability.release()

func exit():
	print("Exiting Swing State.")
	if hook_ability:
		hook_ability.release()
		hook_ability.set_process_mode(Node.PROCESS_MODE_DISABLED)

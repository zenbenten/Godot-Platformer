# SwingState.gd
# Updated to fire the hook based on a direction passed to it.

extends State

var hook_ability

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	hook_ability = player.find_child("GrapplingHookAbility", true, false)

	if hook_ability:
		# --- AIMING LOGIC CHANGED ---
		# Default to the player's facing direction if no aim is provided.
		var aim_direction = msg.get("aim_direction", Vector2(player.facing_direction, 0))
		hook_ability.shoot(aim_direction)
	else:
		state_machine.transition_to("Jump")

func process_physics(_delta: float):
	var player = state_machine.player

	if not hook_ability:
		state_machine.transition_to("Jump")
		return

	if not hook_ability.flying and not hook_ability.hooked:
		state_machine.transition_to("Jump")
		return

	if hook_ability.hooked:
		var chain_velocity = (hook_ability.tip - player.global_position).normalized() * 60
		player.velocity += chain_velocity
	
	player.velocity.y = move_toward(player.velocity.y, player.max_fall_speed, player.gravity * _delta)
	player.move_and_slide()

	if Input.is_action_just_released("item_use"):
		hook_ability.release()

func exit():
	if hook_ability:
		hook_ability.release()

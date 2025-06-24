# SwingState.gd
# Corrected version that properly handles the hook's "flying" and "hooked" phases.

extends State

var hook_ability # A reference to the grappling hook node

func enter(msg: Dictionary = {}):
	var player = state_machine.player
	# Find the ability node. This is more robust than a hardcoded name.
	# We use the name we assigned in Player.gd's add_item function.
	hook_ability = player.find_child("GrapplingHookAbility", true, false)

	if hook_ability:
		var aim_direction = player.get_global_mouse_position() - player.global_position
		hook_ability.shoot(aim_direction)
	else:
		# If for some reason we can't find the hook, exit immediately.
		state_machine.transition_to("Jump")

func process_physics(_delta: float):
	var player = state_machine.player

	# First, a safety check in case the hook node was somehow removed.
	if not hook_ability:
		state_machine.transition_to("Jump")
		return

	# --- NEW, CORRECTED EXIT LOGIC ---
	# If the hook is no longer flying AND it's not hooked to anything,
	# then the grappling action is over. Time to transition away.
	if not hook_ability.flying and not hook_ability.hooked:
		state_machine.transition_to("Jump")
		return

	# --- APPLY SWINGING PHYSICS (Only when hooked) ---
	if hook_ability.hooked:
		# This is the physics logic from before.
		var chain_velocity = (hook_ability.tip - player.global_position).normalized() * 80 # CHAIN_PULL initially 60
		# You can add more complex swing physics here!
		player.velocity += chain_velocity
	
	# Apply gravity and movement regardless of being hooked or just flying.
	player.velocity.y += 60
	player.move_and_slide()

	# --- HANDLE INPUT ---
	# Allow the player to release the hook manually.
	if Input.is_action_just_released("item_use"):
		hook_ability.release()
		# The exit logic at the top of this function will catch this on the next frame
		# and transition the state correctly.

func exit():
	# This function is called when we transition away from the Swing state.
	# We should always ensure the hook is released.
	if hook_ability:
		hook_ability.release()

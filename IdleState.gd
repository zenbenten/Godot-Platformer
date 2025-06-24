# IdleState.gd
# Updated to handle shooting straight up.

extends State

@export var ground_friction = 0.90

func enter(msg: Dictionary = {}):
	pass

func process_physics(_delta: float):
	var player = state_machine.player

	player.velocity.y = move_toward(player.velocity.y, player.max_fall_speed, player.gravity * _delta)
	player.velocity.x = lerp(player.velocity.x, 0.0, ground_friction)
	player.move_and_slide()

	# --- STATE TRANSITIONS ---
	var walk_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if not is_zero_approx(walk_input):
		state_machine.transition_to("Move")
		return

	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {"is_jump": true})
		return

	if Input.is_action_just_pressed("item_use"):
		if player.has_ability("Grappling Hook"):
			var aim_direction = Vector2.ZERO
			
			# Check for look_up input to determine vertical aim
			if Input.is_action_pressed("look_up"):
				# Since we are idle, there is no horizontal input, so we aim straight up.
				aim_direction = Vector2.UP
			else:
				# If not looking up, aim straight horizontally based on facing direction.
				aim_direction = Vector2(player.facing_direction, 0)
				
			state_machine.transition_to("Swing", {"aim_direction": aim_direction.normalized()})
			return
			
	if not player.is_on_floor():
		state_machine.transition_to("Jump")
		return

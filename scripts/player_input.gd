# PlayerInput.gd
extends Node

func _physics_process(_delta):
	if not get_parent().is_multiplayer_authority():
		return

	# Send movement input to the server for the authority to process.
	var direction_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	get_parent().server_set_movement_input.rpc(direction_input)

	# If jump is pressed, send a one-shot RPC.
	if Input.is_action_just_pressed("jump"):
		get_parent().server_request_jump.rpc()

	# Send item use request.
	if Input.is_action_just_pressed("item_use"):
		var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		var vertical_input = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		var aim_direction = Vector2(horizontal_input, vertical_input)
		if aim_direction == Vector2.ZERO:
			aim_direction = Vector2(get_parent().facing_direction, 0)
		get_parent().server_request_item_use.rpc(aim_direction.normalized())

	# NEW: Send item release request.
	if Input.is_action_just_released("item_use"):
		get_parent().server_request_item_release.rpc()

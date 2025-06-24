extends State

# You can export variables to tweak them in the Inspector!
@export var speed = 500
@export var friction = 0.85

func enter(msg: Dictionary = {}):
	# Maybe play a "run" animation
	pass

func process_physics(_delta: float):
	# Get player reference from the state machine
	var player = state_machine.player

	# Get input
	var walk = Input.get_action_strength("right") - Input.get_action_strength("left")
	player.velocity.x += walk * speed

	# Apply gravity
	player.velocity.y += 60 # Using your gravity value

	# Apply friction
	player.velocity.x *= friction

	player.move_and_slide()

	# --- State Transitions ---
	if not player.is_on_floor():
		state_machine.transition_to("Jump") # Or a "Fall" state
	elif is_zero_approx(walk):
		state_machine.transition_to("Idle")
	
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump", {"is_jump": true})

	# ... inside process_physics ...
		if Input.is_action_just_pressed("item_use"):
	# Check if the player has the ability AND we are on the ground
			if state_machine.player.has_ability("Grappling Hook"):
				state_machine.transition_to("Swing")

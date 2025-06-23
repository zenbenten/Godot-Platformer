# GrappleState.gd
# This state manages all logic when the player is actively grappling.
# It assumes exclusive control over the player's velocity.
extends State

#== EXPORTED VARIABLES FOR TUNING ==#
@export var grapple_speed: float = 800.0
@export var arrival_threshold: float = 20.0
@export var rope_deploy_time: float = 0.15
@export var release_momentum_multiplier: float = 1.2

#== NODES ==#
@onready var line_2d: Line2D = $"../../Line2D" # Path to the Line2D node for the rope.

#== STATE VARIABLES ==#
var hook_target_pos: Vector2
var current_deploy_time: float = 0.0

func on_enter() -> void:
	"""
	Called by the StateMachine upon entering this state.
	Initializes visuals and physics for the grapple.
	"""
	line_2d.visible = true
	player.velocity.y = 0 # Nullify gravity's effect from the previous state.
	
	# Reset the rope animation timer.
	current_deploy_time = 0.0
	if line_2d.material:
		line_2d.material.set_shader_parameter("progress", 0.0)

func on_exit() -> void:
	"""
	Called by the StateMachine upon exiting this state.
	Cleans up visuals and applies momentum.
	"""
	line_2d.visible = false
	line_2d.clear_points()
	
	# Apply a momentum boost for a satisfying slingshot effect.
	player.velocity *= release_momentum_multiplier

func state_process(delta: float) -> State:
	"""
	The per-frame logic loop. Handles movement, visuals, and exit checks.
	"""
	# Exit Condition: Player has arrived at the destination.
	if player.global_position.distance_to(hook_target_pos) < arrival_threshold:
		return owner.get_node("AirState")

	# --- Physics Authority ---
	# This state has full control over velocity.
	var direction = player.global_position.direction_to(hook_target_pos)
	player.velocity = direction * grapple_speed
	
	# --- Visuals ---
	update_rope_visual()
	animate_rope_deployment(delta)
	
	return null # Remain in this state.

func state_input(event: InputEvent) -> State:
	"""
	Handles input-based exit conditions.
	"""
	# Exit Condition: Player releases the grapple button.
	if event.is_action_released("grapple"):
		return owner.get_node("AirState")
		
	# Exit Condition: Player presses jump to cancel and get a small boost.
	if event.is_action_just_pressed("jump"):
		# Assumes 'jump_velocity' is a property on the main Player script.
		player.velocity.y = -player.jump_velocity 
		return owner.get_node("AirState")

	return null

#== HELPER FUNCTIONS ==#
func update_rope_visual() -> void:
	"""
	Updates the Line2D points to draw the rope from player to anchor.
	"""
	# Add points if they don't exist, which is good practice.
	if line_2d.get_point_count() < 2:
		line_2d.add_point(Vector2.ZERO)
		line_2d.add_point(Vector2.ZERO)
		
	# Points are in the Line2D's local space. We need to convert the player's
	# global position and the hook's global position into that local space.
	# Since the Line2D is a sibling of the player, its global_transform can be used.
	var local_player_pos = line_2d.to_local(player.global_position)
	var local_hook_pos = line_2d.to_local(hook_target_pos)
	
	line_2d.set_point_position(0, local_player_pos)
	line_2d.set_point_position(1, local_hook_pos)

func animate_rope_deployment(delta: float) -> void:
	"""
	Updates the shader uniform to animate the rope extending.
	"""
	if line_2d.material and current_deploy_time < rope_deploy_time:
		current_deploy_time += delta
		var deploy_progress = min(current_deploy_time / rope_deploy_time, 1.0)
		line_2d.material.set_shader_parameter("progress", deploy_progress)

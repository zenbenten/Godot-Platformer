# Player.gd (Revised for Projectile Chain)
extends CharacterBody2D

# --- CHARACTER PHYSICS CONSTANTS ---
@export var jump_force: float = 1550.0
@export var move_speed: float = 500.0
@export var gravity_amount: float = 60.0
@export var max_speed: float = 2000.0
@export var friction_air: float = 0.95
@export var friction_ground: float = 0.85
@export var chain_pull_force: float = 105.0

# --- SHARED STATE VARIABLES ---
var can_jump: bool = false
var hooked: bool = false

# --- NODE REFERENCES ---
@onready var state_machine = $StateMachine
@onready var pinjoint: PinJoint2D = $PinJoint2D
@onready var line: Line2D = $Line2D
@export var chain: Node2D # Creates a slot in the Inspector

var grapple_hook_data: Dictionary = {}

func _ready():
	# Connect the chain's signal to a function on this player script.
	# This is the core of our new communication method.
	chain.chain_hooked.connect(_on_chain_hooked)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Tell the chain to shoot towards the mouse cursor
			chain.shoot(get_global_mouse_position() - global_position)
		else:
			# Tell the chain to release
			chain.release()
			# If we are currently hooked, releasing the mouse should detach us
			if state_machine.current_state.name == "Hooked":
				state_machine.change_state("Air")

# This function is called automatically when the chain emits its "chain_hooked" signal.
func _on_chain_hooked(hook_point, hook_body):
	self.grapple_hook_data = {"point": hook_point, "body": hook_body}
	state_machine.change_state("Hooked")

func _physics_process(_delta: float):
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)
	
	move_and_slide()
	
	# The rope drawing now uses the chain's state.
	_update_rope()

func _update_rope():
	# We draw the rope if the chain script says it's hooked.
	if chain.hooked:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		# Draw a line from the player to the chain's tip.
		line.add_point(to_local(chain.tip_position))
	else:
		line.clear_points()

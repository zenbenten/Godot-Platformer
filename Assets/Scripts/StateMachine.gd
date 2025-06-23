# StateMachine.gd
extends Node

@export var initial_state: State # Assign the "Move" node here in the Inspector!

var current_state: State
var states: Dictionary = {} # A dictionary of all available states, keyed by name

func _ready():
	# Store a reference to all child nodes (our states) in the dictionary.
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self # Give each state a reference back to this state machine.
	
	# Start in the initial state.
	if initial_state:
		change_state(initial_state.name)

func _physics_process(delta: float):
	# Delegate the physics process to the active state.
	if current_state:
		current_state.process_physics(delta)

func change_state(new_state_name: String):
	# Make sure the new state exists.
	if not states.has(new_state_name):
		return

	# If we have a current state, call its exit function.
	if current_state:
		current_state.exit()

	# Set the new state and call its enter function.
	current_state = states[new_state_name]
	current_state.enter()

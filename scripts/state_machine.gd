# StateMachine.gd
# Safer version that checks if child nodes are valid states.

extends Node

@export var initial_state: State

var current_state: State
var player: CharacterBody2D

func _ready():
	player = get_parent() # Assumes StateMachine is a direct child of Player
	
	# Add all child nodes (the states) to a dictionary by name
	for state in get_children():
		# This 'if' statement is the safety check.
		# It ensures we only try to modify nodes that actually extend our State class.
		if state is State:
			state.state_machine = self # Give each state a reference to this FSM
		else:
			# This warning will print in the output log if you have a child node
			# without a state script attached, making it easy to debug.
			print("Warning: Child node '", state.name, "' is not a State and will be ignored by the StateMachine.")

	# Start in the initial state
	if initial_state:
		current_state = initial_state
		
		# A final safety check to ensure the initial_state itself is valid before using it.
		if not initial_state is State:
			print("Error: Initial state '", initial_state.name, "' is not a valid state script. State machine cannot start.")
			current_state = null # Stop the state machine from running
			return
			
		# This ensures the state_machine reference is set even if the initial_state isn't a child (not recommended, but safe)
		if not initial_state.state_machine:
			initial_state.state_machine = self

		current_state.enter()

func _input(event: InputEvent):
	if current_state:
		current_state.process_input(event)

func _process(delta: float):
	if current_state:
		current_state.process_frame(delta)

func _physics_process(delta: float):
	if current_state:
		current_state.process_physics(delta)

func transition_to(state_name: String, msg: Dictionary = {}):
	# Don't transition if there's no state to transition from.
	if not current_state:
		return
		
	var new_state = get_node(state_name)
	
	# Check if the new state exists and is a valid state.
	if not new_state is State:
		print("Warning: Cannot transition to '", state_name, "' because it is not a valid state.")
		return
		
	# Don't transition to the same state.
	if current_state == new_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter(msg) # Pass optional message dictionary

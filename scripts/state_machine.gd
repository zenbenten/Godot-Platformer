# StateMachine.gd
extends Node

@export var initial_state: State

var current_state: State
var player: CharacterBody2D

func _ready():
	player = get_parent()
	
	for state in get_children():
		if state is State:
			state.state_machine = self
		else:
			print("Warning: Child node '", state.name, "' is not a State and will be ignored by the StateMachine.")

	if initial_state:
		current_state = initial_state
		if not initial_state is State:
			print("Error: Initial state '", initial_state.name, "' is not a valid state script.")
			current_state = null
			return
		if not initial_state.state_machine:
			initial_state.state_machine = self
		# DEBUG: Announce initialization and starting state.
		print("[StateMachine for Player ", player.name, "] Initialized. Initial state: ", initial_state.name)
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
	if not current_state:
		return
	var new_state = get_node(state_name)
	if not new_state is State:
		print("Warning: Cannot transition to '", state_name, "' because it is not a valid state.")
		return
	if current_state == new_state:
		return
	if current_state:
		# DEBUG: Announce state transition.
		print("[StateMachine] Transitioning from '", current_state.name, "' to '", new_state.name, "'.")
		current_state.exit()
	current_state = new_state
	current_state.enter(msg)

# NEW: RPC function to receive item input events from the Player script.
@rpc("any_peer", "call_local")
func remote_handle_item_input(press: bool, release: bool, aim_vector: Vector2):
	# DEBUG: (2) The host's State Machine receives the event
	print("(2) [StateMachine for Player ", player.name, "] Received item input event.")
	# When an input event is received, pass it to the active state.
	if current_state:
		current_state.on_item_input(press, release, aim_vector)

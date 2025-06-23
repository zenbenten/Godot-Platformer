# State.gd
# Base class for all states.
class_name State
extends Node

# A reference to the state machine, which will be set by the StateMachine itself.
var state_machine = null

# Virtual function. Called when entering the state.
func enter():
	pass

# Virtual function. Called when exiting thestate.
func exit():
	pass

# Virtual function. Corresponds to _process().
func process_frame(_delta: float):
	pass
	
# Virtual function. Corresponds to _physics_process().
func process_physics(_delta: float):
	pass

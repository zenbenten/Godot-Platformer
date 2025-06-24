class_name State
extends Node

# A reference to the StateMachine, which will be set by the StateMachine itself.
var state_machine = null

# Virtual function, called when entering the state.
func enter(msg: Dictionary = {}):
	pass

# Virtual function, called when exiting the state.
func exit():
	pass

# Virtual function for handling input events.
func process_input(_event: InputEvent):
	pass

# Virtual function for frame-based updates.
func process_frame(_delta: float):
	pass

# Virtual function for physics-based updates.
func process_physics(_delta: float):
	pass

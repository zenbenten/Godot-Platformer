# State.gd
class_name State
extends Node

var state_machine = null

func enter(_msg: Dictionary = {}):
	pass

func exit():
	pass

func process_input(_event: InputEvent):
	pass

func process_frame(_delta: float):
	pass

func process_physics(_delta: float):
	pass

# NEW: Virtual function to handle item input events sent from the StateMachine.
func on_item_input(_press: bool, _release: bool, _aim_vector: Vector2):
	pass

# Player.gd
# Added a 'facing_direction' variable to remember the last direction moved.

extends CharacterBody2D

# --- ADVANCED PHYSICS VARIABLES ---
var max_run_speed = 100
var run_accel = 800
var gravity = 1000
var max_fall_speed = 160
var jump_force = -160
var jump_hold_time = 0.2
var current_jump_hold_time = 0.0

# --- NEW VARIABLE ---
# Stores the last direction the player was facing (1 for right, -1 for left).
var facing_direction = 1

# The player's inventory of abilities, stored by name.
var abilities = {}

# A direct reference to the state machine.
@onready var state_machine = $StateMachine

func _ready():
	pass

func add_item(item_resource: ItemResource):
	if not abilities.has(item_resource.item_name):
		abilities[item_resource.item_name] = item_resource
		if item_resource.ability_scene:
			var ability_instance = item_resource.ability_scene.instantiate()
			ability_instance.name = item_resource.ability_scene.get_path().get_file().get_basename()
			add_child(ability_instance)
		print("Picked up: ", item_resource.item_name)

func has_ability(ability_name: String) -> bool:
	return abilities.has(ability_name)

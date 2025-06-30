# Player.gd
# Added a timestamp variable for the jump buffer.
class_name Player
extends CharacterBody2D

# --- MOVEMENT ---
@export_category("Movement")
@export var max_speed = 500.0
@export var acceleration = 9000.0
@export var ground_deceleration = 9000.0
@export var air_deceleration = 1500.0

# --- JUMPING ---
@export_category("Jumping")
@export var jump_velocity = -500.0
@export var jump_end_early_gravity_modifier = 2.0

# --- GRAVITY ---
@export_category("Gravity")
@export var gravity = 1000.0
@export var fall_gravity_multiplier = 2.0
@export var swing_gravity_multiplier = 0.0
@export var grounding_force = 10.0

# --- GAME FEEL (THE IMPORTANT STUFF!) ---
@export_category("Game Feel")
@export var coyote_time = 0.2
@export var jump_buffer = 0.2 # This will now be used correctly!

# --- State-Tracking Variables (managed by the states) ---
var time_left_ground = 0.0
var jump_to_consume = false
var time_jump_was_buffered = 0.0 # NEW: Stores the timestamp of the buffered jump.

# --- Other Player Properties ---
var facing_direction = 1
var abilities = {}
@onready var state_machine = $StateMachine

func _ready():
	pass

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

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

# Player.gd
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
@export var jump_buffer = 0.2

# --- ITEM DROPPING ---
@export_category("Item Dropping")
@export var dropped_item_scene: PackedScene
# NEW: Controls the upward force of the drop arc.
@export var drop_up_force = -350.0
# NEW: Controls the horizontal force of the drop arc.
@export var drop_away_force = 200.0


# --- State-Tracking Variables (managed by the states) ---
var time_left_ground = 0.0
var jump_to_consume = false
var time_jump_was_buffered = 0.0

# --- Other Player Properties ---
var facing_direction = 1
var current_item: ItemResource = null
@onready var state_machine = $StateMachine

func _ready():
	set_multiplayer_authority(int(str(name)))
	$Camera2D.enabled = is_multiplayer_authority()

# This new function handles dropping the current item.
func drop_item():
	if not current_item:
		return

	var ability_node_name = current_item.ability_scene.get_path().get_file().get_basename()
	var ability_node = find_child(ability_node_name, true, false)
	if ability_node:
		ability_node.queue_free()

	if dropped_item_scene:
		var dropped_item = dropped_item_scene.instantiate()
		dropped_item.item = current_item
		# --- UPDATED SPAWN POSITION ---
		# Spawn the item slightly above the player's head.
		dropped_item.position = self.global_position + Vector2(0, -64)
		get_tree().current_scene.add_child(dropped_item)

		# --- UPDATED VELOCITY CALCULATION ---
		# Calculate the initial velocity for the arc.
		var drop_velocity = Vector2(-self.facing_direction * drop_away_force, drop_up_force)
		# Pass this velocity to the dropped item.
		dropped_item.initialize_drop(drop_velocity)

	current_item = null
	print("Item dropped.")

func add_item(item_resource: ItemResource):
	if current_item:
		drop_item()
	
	current_item = item_resource
	
	if current_item.ability_scene:
		var ability_instance = current_item.ability_scene.instantiate()
		ability_instance.name = current_item.ability_scene.get_path().get_file().get_basename()
		add_child(ability_instance)
	print("Picked up: ", current_item.item_name)

func has_ability(ability_name: String) -> bool:
	return current_item and current_item.item_name == ability_name

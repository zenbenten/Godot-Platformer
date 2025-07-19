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
@export var drop_up_force = -350.0
@export var drop_away_force = 200.0

# --- State-Tracking Variables (managed by the states) ---
var time_left_ground = 0.0
var jump_to_consume = false
var time_jump_was_buffered = 0.0

# --- Other Player Properties ---
var facing_direction = 1
var current_item: ItemResource = null
@onready var state_machine = $StateMachine

# --- Authoritative Host Input State ---
var client_input_direction = 0.0
var client_is_holding_jump = false
var client_wants_to_jump = false

func _ready():
	set_multiplayer_authority(1)
	$Chain.set_multiplayer_authority(1)
	$Camera2D.enabled = (int(str(name)) == multiplayer.get_unique_id())

func _physics_process(delta):
	if int(str(name)) != multiplayer.get_unique_id():
		return

	# 1. Capture all inputs.
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	var holding_jump = Input.is_action_pressed("jump")
	var wants_jump = Input.is_action_just_pressed("jump")
	var wants_item_use = Input.is_action_just_pressed("item_use")
	var wants_item_release = Input.is_action_just_released("item_use")

	# 2. Send movement/jump state to the host via RPC.
	send_movement_input_to_host.rpc_id(1, direction, holding_jump, wants_jump)

	# 3. If an item event happened, send a separate RPC to the StateMachine.
	if wants_item_use or wants_item_release:
		var aim_vec = Vector2.ZERO
		if wants_item_use:
			var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
			var v_input = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
			aim_vec = Vector2(h_input, v_input)
		$StateMachine.rpc_id(1, "remote_handle_item_input", wants_item_use, wants_item_release, aim_vec)

@rpc("any_peer", "call_local")
func send_movement_input_to_host(direction, holding_jump, wants_jump):
	# Security check to ensure the sender is the owner of this node.
	if multiplayer.get_remote_sender_id() != 0 and multiplayer.get_remote_sender_id() != int(str(name)):
		return
		
	client_input_direction = direction
	client_is_holding_jump = holding_jump
	if wants_jump: client_wants_to_jump = true

# This is called by the item_pickup script.
func pickup_item(new_item_resource: ItemResource):
	# If the player is already holding an item, they cannot pick up a new one.
	if self.current_item:
		print("Cannot pick up item, already holding one.")
		return
	
	# If empty-handed, equip the new item.
	self.current_item = new_item_resource
	print("Picked up: ", self.current_item.item_name)

# This is called by the State Machine for a manual drop command.
func manual_drop_item():
	if current_item:
		var item_to_drop = current_item
		current_item = null
		drop_item(item_to_drop)

# This function handles the logic of spawning a dropped item.
func drop_item(item_to_drop: ItemResource):
	if not item_to_drop:
		return
	
	if item_to_drop.item_name == "Grappling Hook":
		var ability_node = get_node("Chain")
		if is_instance_valid(ability_node):
			ability_node.release()

	var world = get_tree().get_root().get_node("Game/World")
	if world:
		var dropped_item = dropped_item_scene.instantiate()
		dropped_item.name = "ItemPickup_" + str(Time.get_ticks_msec())
		world.get_node("OnlineEntities").add_child(dropped_item)

		var spawn_pos = self.global_position + Vector2(0, -64)
		var drop_velocity = Vector2(-self.facing_direction * drop_away_force, drop_up_force)
		
		dropped_item.setup_dropped_item(item_to_drop.resource_path, spawn_pos, drop_velocity)
		world.rpc("spawn_item_on_client", dropped_item_scene.resource_path, dropped_item.name, spawn_pos, drop_velocity, item_to_drop.resource_path)
			
	print("Item dropped: ", item_to_drop.item_name)

func has_ability(ability_name: String) -> bool:
	return current_item and current_item.item_name == ability_name

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
# These variables are set on the HOST by client RPCs. The state machine reads these.
var client_input_direction = 0.0
var client_is_holding_jump = false
var client_wants_to_jump = false
var client_wants_to_use_item = false
var client_item_aim_vector = Vector2.ZERO


func _ready():
	# Every player instance recognizes the host (peer ID 1) as its authority.
	set_multiplayer_authority(1)

	# This line now handles both enabling the correct camera and disabling
	# all others. It checks if the character's ID (its name) matches the
	# game client's ID. It will be 'true' for your character and 'false'
	# for everyone else's character on your screen.
	$Camera2D.enabled = (int(str(name)) == multiplayer.get_unique_id())

func _physics_process(delta):
	# This block only runs on the client that "owns" this character.
	# Its only job is to capture input and send it to the host (peer ID 1).
	if int(str(name)) == multiplayer.get_unique_id():
		# Capture all relevant inputs for this frame.
		var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
		var holding_jump = Input.is_action_pressed("jump")
		var wants_jump = Input.is_action_just_pressed("jump")
		var wants_item_use = Input.is_action_just_pressed("item_use")
		var aim_vec = Vector2.ZERO
		
		if wants_item_use:
			var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
			var v_input = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
			aim_vec = Vector2(h_input, v_input)

		# Send all captured inputs to the host via an RPC call.
		send_input_to_host.rpc_id(1, direction, holding_jump, wants_jump, wants_item_use, aim_vec)


# This RPC function will be executed ON THE HOST when a client calls it.
@rpc("any_peer", "call_local")
func send_input_to_host(direction, holding_jump, wants_jump, wants_item_use, aim_vec):
	# A security check to make sure only the correct client can control this character.
	if multiplayer.get_remote_sender_id() != int(str(name)):
		return

	# Store the received inputs in our variables so the state machine can use them.
	client_input_direction = direction
	client_is_holding_jump = holding_jump
	# Only set "wants" flags if they are true, they will be reset by the state machine.
	if wants_jump:
		client_wants_to_jump = true
	if wants_item_use:
		client_wants_to_use_item = true
	client_item_aim_vector = aim_vec


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
		dropped_item.position = self.global_position + Vector2(0, -64)
		get_tree().current_scene.add_child(dropped_item)
		var drop_velocity = Vector2(-self.facing_direction * drop_away_force, drop_up_force)
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

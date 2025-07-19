# world.gd
class_name World
extends Node2D

@export var player_scene:PackedScene
@export var player_spawner: MultiplayerSpawner

func _ready() -> void:
	player_spawner.spawn_function = _ms_player
	
	# This line is a failsafe to prevent errors if the ItemSpawner is used for anything else.
	if has_node("ItemSpawner"):
		$ItemSpawner.spawn_function = Callable()
	
	# DEBUG: Announce that the world is ready.
	print("[World] Ready.")

# This is the new RPC function that the host calls on all clients.
@rpc("any_peer")
func spawn_item_on_client(item_scene_path, item_name, spawn_pos, initial_velocity, item_resource_path):
	# DEBUG: (7) The world receives the RPC to spawn the item for the client
	print("(7) [World on client ", multiplayer.get_unique_id(), "] Received RPC to spawn item '", item_name, "'.")
	
	var item_scene = load(item_scene_path)
	var new_item = item_scene.instantiate()
	new_item.name = item_name
	
	# Add the new item to the client's scene tree
	$OnlineEntities.add_child(new_item)
	
	# Now that the item exists on the client, configure it with the data from the host.
	new_item.setup_dropped_item(item_resource_path, spawn_pos, initial_velocity)

func spawn_player(authority_pid: int) -> void:
	print("5. [World] 'spawn_player' called for pid: " + str(authority_pid))
	player_spawner.spawn(authority_pid)

func _ms_player(authority_pid: int) -> Player:
	print("6. [World] Custom spawn function '_ms_player' is running.")
	
	if not player_scene:
		print("ERROR: [World] Player Scene is not set in the Inspector!")
		return null
		
	var player = player_scene.instantiate()
	player.name = str(authority_pid)
	player.position = Vector2(1280/2, 720/2)
	
	print("7. [World] Player scene instantiated successfully for pid: " + str(authority_pid))
	
	return player

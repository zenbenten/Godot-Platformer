# world.gd
class_name World
extends Node2D

@export var player_scene:PackedScene
@export var player_spawner: MultiplayerSpawner

func _ready() -> void:
	player_spawner.spawn_function = _ms_player

func spawn_player(authority_pid: int) -> void:
	# DEBUG: Check if the spawn_player function was called
	print("5. [World] 'spawn_player' called for pid: " + str(authority_pid))
	player_spawner.spawn(authority_pid)

func _ms_player(authority_pid: int) -> Player:
	# DEBUG: Check if the MultiplayerSpawner is calling our custom function
	print("6. [World] Custom spawn function '_ms_player' is running.")
	
	# DEBUG: A crucial check to see if the player_scene variable is assigned in the Inspector
	if not player_scene:
		print("ERROR: [World] Player Scene is not set in the Inspector!")
		return null # Stop execution here to prevent a crash
		
	var player = player_scene.instantiate()
	player.name = str(authority_pid)
	player.position = Vector2(1280/2, 720/2)
	
	# DEBUG: Confirm the player was instantiated successfully
	print("7. [World] Player scene instantiated successfully for pid: " + str(authority_pid))
	
	return player

class_name Main
extends Node2D

@export var player_scene:PackedScene
@export var player_spawner: MultiplayerSpawner

func _ready() -> void:
	player_spawner.spawn_function = _ms_player

func spawn_player(authority_pid: int) -> void:
	player_spawner.spawn(authority_pid)

func _ms_player(authority_pid: int) -> Player:
	var player = player_scene.instantiate()
	player.name = str(authority_pid)
	
	return player

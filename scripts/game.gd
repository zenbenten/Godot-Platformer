# game.gd
extends Node

@onready var world: World = $World

func _on_connection_manager_hosting() -> void:
	# DEBUG: Check if the 'hosting' signal was received from ConnectionManager
	print("4. [Game] Received 'hosting' signal. Calling 'world.spawn_player'.")
	world.spawn_player(1)
	
	multiplayer.peer_connected.connect(
		func(pid) -> void:
			world.spawn_player(pid)
	)

extends Node

@onready var main: Main = $Main

func _on_connection_manager_hosting() -> void:
	main.spawn_player(1)
	
	multiplayer.peer_connected.connect(
		func(pid) -> void:
			main.spawn_player(pid)
	)

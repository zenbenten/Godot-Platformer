class_name ENetConnectionManager
extends PanelContainer

signal server_created
signal server_joined

@export var host_ip: LineEdit
@export var host_port: LineEdit

var peer = ENetMultiplayerPeer.new()

func _on_host_e_net_pressed() -> void:
	# DEBUG: Check if the button press is detected
	print("1. [ENetManager] Host button pressed.")
	
	peer.create_server(int(host_port.text))
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid) -> void:
			print(str(pid) + " has connected.")
	)
	
	# DEBUG: Check if the signal is about to be emitted
	print("2. [ENetManager] Emitting 'server_created' signal.")
	server_created.emit()
	
func _on_join_pressed() -> void:
	peer.create_client(host_ip.text, int(host_port.text))
	multiplayer.multiplayer_peer = peer
	
	server_joined.emit()

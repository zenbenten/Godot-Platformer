# connectionManager.gd
class_name ConnectionManager
extends Control

signal hosting
signal joining

@export var enet: ENetConnectionManager

func _ready() -> void:
	enet.server_created.connect(_host_handler)
	enet.server_joined.connect(_join_handler)

func _host_handler() -> void:
	# DEBUG: Check if the signal from ENetManager was received
	print("3. [ConnectionManager] Received 'server_created' signal. Emitting 'hosting' signal.")
	hosting.emit()
	hide()
	
func _join_handler() -> void:
	joining.emit()
	hide()

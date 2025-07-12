# Chain.gd
class_name Chain
extends Node2D

@onready var links = $Links
var direction := Vector2(0,0)
var tip := Vector2(0,0)
const SPEED = 50

var flying = false
var hooked = false

@rpc("any_peer", "call_local")
func shoot(dir: Vector2) -> void:
	direction = dir.normalized()
	flying = true
	hooked = false
	tip = self.global_position

@rpc("any_peer", "call_local")
func release() -> void:
	flying = false
	hooked = false
	self.visible = false 
	# Add this line to disable the node until its next use.
	process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float):
	self.visible = flying or hooked
	if not self.visible:
		return
	
	var tip_loc = to_local(tip)
	links.rotation = self.position.angle_to_point(tip_loc) + deg_to_rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) + deg_to_rad(90)
	links.position = tip_loc/2
	links.region_rect.size.y = tip_loc.length()

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	$Tip.global_position = tip
	
	if flying:
		var collision = $Tip.move_and_collide(direction * SPEED)
		if collision:
			hooked = true
			flying = false
			
	tip = $Tip.global_position

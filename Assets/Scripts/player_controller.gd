# Player.gd (The simplified main script)
extends CharacterBody2D

# --- SHARED VARIABLES ---
# These are properties that any state might need to access.
@export var speed: int = 300
@export var jump_force: int = 400

@onready var pinjoint: PinJoint2D = $PinJoint2D
@onready var line: Line2D = $Line2D
@onready var raycast_container = $RayCastContainer

var grapple_hook_data: Dictionary = {}

var hooked = false # This can be used by the Line2D logic
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# The player script no longer needs a _physics_process!
# The active state handles velocity, and we just apply it here.
func _physics_process(_delta):
	# The state machine will modify player.velocity.
	# We just need to apply the final movement and draw the rope.
	move_and_slide()
	_update_rope()

# This helper function can stay on the player since multiple states might need it.
func find_closest_hook_point():
	var closest_point = Vector2.ZERO
	var closest_body = null
	var closest_distance = INF
	var rays = raycast_container.get_children()

	for ray in rays:
		ray.force_raycast_update()

	for ray in rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider and collider.is_in_group("Hookable"):
				var collision_point = ray.get_collision_point()
				var distance = global_position.distance_squared_to(collision_point)
				if distance < closest_distance:
					closest_distance = distance
					closest_point = collision_point
					closest_body = collider
					
	if closest_body:
		return {"point": closest_point, "body": closest_body}
	
	return null

func _update_rope():
	if hooked and pinjoint:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(pinjoint.global_position))
	else:
		line.clear_points()

extends CharacterBody2D

@export var speed: int = 300
@export var jump_force: int = 400
@export var pinjoint: PinJoint2D

@onready var line = $Line2D
@onready var raycast_container = $RayCastContainer # Get the container for our rays

var hooked = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# REMOVED: All _on_hookable_... functions and the hookable_targets array.

func _ready():
	if not pinjoint:
		push_error("PinJoint has NOT been assigned in the Inspector!")
		return
	if not raycast_container:
		push_error("RayCastContainer node not found! Make sure it's a child of the player.")
		return
	
	pinjoint.node_a = get_path()


func _physics_process(delta):
	if not pinjoint: return

	# Hook system
	if Input.is_action_just_pressed("item_use") and not hooked:
		# find_closest_hook_point now returns a Dictionary with the point and the body
		var hook_data = find_closest_hook_point()
		
		if hook_data: # If the dictionary is not null
			hooked = true
			pinjoint.global_position = hook_data["point"]  # Use the precise collision point
			pinjoint.node_b = hook_data["body"].get_path() # Connect to the body we hit
	
	elif Input.is_action_just_released("item_use") and hooked:
		hooked = false
		pinjoint.node_b = NodePath("")
	
	_update_rope()
	_handle_movement(delta)
	move_and_slide()


# This is the new core logic that replaces the Area2D system.
func find_closest_hook_point():
	var closest_point = Vector2.ZERO
	var closest_body = null
	var closest_distance = INF

	# Force the rays to update their collision status right now.
	# This is important because we are not in the main physics step.
	for ray in raycast_container.get_children():
		ray.force_raycast_update()

	# Loop through all the rays in our container
	for ray in raycast_container.get_children():
		# Check if this specific ray hit something
		if ray.is_colliding():
			var collider = ray.get_collider()
			
			# Check if the thing it hit is in the "Hookable" group
			if collider.is_in_group("Hookable"):
				var collision_point = ray.get_collision_point()
				var distance = global_position.distance_squared_to(collision_point)
				
				if distance < closest_distance:
					closest_distance = distance
					closest_point = collision_point
					closest_body = collider
					
	if closest_body:
		# Return all the data we need in a single dictionary
		return {"point": closest_point, "body": closest_body}
	
	# If we didn't find anything, return null
	return null


func _update_rope():
	if hooked and pinjoint:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(pinjoint.global_position))
	else:
		line.clear_points()


func _handle_movement(delta):
	var move_input = Input.get_axis("move_left", "move_right")
	
	if not hooked:
		velocity.x = move_input * speed
		if not is_on_floor():
			velocity.y += gravity * delta
	else:
		var swing_influence = move_input * speed * 0.5
		velocity.x += swing_influence * delta
		
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_force

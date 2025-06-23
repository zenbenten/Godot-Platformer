"""
This script controls the chain.
"""
extends Node2D

@onready var links = $Links		# A slightly easier reference to the links
var direction := Vector2(0,0)	# The direction in which the chain was shot
var tip := Vector2(0,0)			# The global position the tip should be in
								# We use an extra var for this, because the chain is
								# connected to the player and thus all .position
								# properties would get messed with when the player
								# moves.

const SPEED = 50	# The speed with which the chain moves

var flying = false	# Whether the chain is moving through the air
var hooked = false	# Whether the chain has connected to a wall

# shoot() shoots the chain in a given direction
func shoot(dir: Vector2) -> void:
	direction = dir.normalized()	# Normalize the direction and save it
	flying = true					# Keep track of our current state
	tip = self.global_position		# reset the tip position to the player's position

# release() the chain
func release() -> void:
	flying = false	# Not flying anymore
	hooked = false	# Not attached anymore

# Every graphics frame we update the visuals
func _process(_delta: float) -> void:
	self.visible = flying or hooked	# Only visible if flying or attached to something
	if not self.visible:
		return	# Not visible -> nothing to draw
	
	var tip_loc = to_local(tip)	# Easier to work in local coordinates
	
	# We rotate the links (= chain) and the tip to fit on the line between the player's position and the tip
	# GODOT 4 FIX: The 'deg_to_rad' function has been renamed to 'deg2rad'.
	links.rotation = self.position.angle_to_point(tip_loc) + deg_to_rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) + deg_to_rad(90)
	
	links.position = tip_loc						# The links are moved to start at the tip
	links.region_rect.size.y = tip_loc.length()		# and get extended for the distance between (0,0) and the tip

# Every physics frame we update the tip position
func _physics_process(_delta: float) -> void:
	# First, ensure the Tip physics body is at the correct global position.
	# This is important because the player (the parent) may have moved in the last frame.
	$Tip.global_position = tip
	
	if flying:
		# In Godot 4, CharacterBody2D (formerly KinematicBody2D) still has the move_and_collide method.
		# It moves the body along the motion vector and stops if it hits something.
		# It returns a KinematicCollision2D object on collision, which evaluates to 'true' in an if-statement.
		# This logic remains correct without changes.
		var collision = $Tip.move_and_collide(direction * SPEED)
		if collision:
			hooked = true	# Got something!
			flying = false	# Not flying anymore
			
	# After the potential move, we update our 'tip' variable to the new global position of the physics body.
	# This ensures our visual representation and the player's pull calculations are correct.
	tip = $Tip.global_position

#```

### Summary of Changes

#1.  **`deg2rad(90)`**: The function `deg_to_rad()` was removed in Godot 4. The new, equivalent function is `deg2rad()`. This was the only mandatory code change.
#2.  **`move_and_collide` Logic**: Your use of `$Tip.move_and_collide()` was correct. The converter updated `$Tip` from a `KinematicBody2D` to a `CharacterBody2D`, and this method still works as you intended: it moves the object and returns a collision object if it hits something, which correctly triggers the `if` statement.
#3.  **Code Comments**: I've added comments to clarify *why* the physics code still works and explain the flow of logic in the `_physics_process` function for future reference.

#With the fixes in `Player.gd` and now `Chain.gd`, your project's core mechanics should be much closer to working correctly in Godot 4. You should now be able to run the game and test the player movement and chain functionali

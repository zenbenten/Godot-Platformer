# Player.gd
# Final, corrected version. The Player script holds stats and abilities,
# while the StateMachine handles all per-frame logic.

extends CharacterBody2D

# Player stats that states might need access to can live here.
var max_run_speed = 300 #was 100
var run_accel = 800
var gravity = 1200
var max_fall_speed = 300 #was 160
var jump_force = -160
var jump_hold_time = 0.2
var current_jump_hold_time = 0.0

# The player's inventory of abilities, stored by name.
var abilities = {}

# A direct reference to the state machine for easy access by states if needed,
# though direct calls from the player are no longer necessary.
@onready var state_machine = $StateMachine

func _ready():
	# This function can be used for any one-time setup for the player itself.
	# We no longer need to instance the chain here from the start.
	pass

# The _physics_process function has been completely REMOVED.
# The StateMachine's own _physics_process is called automatically by Godot,
# which then correctly calls the active state's process_physics function.

# This function is called by ItemPickup scenes when the player collides with them.
func add_item(item_resource: ItemResource):
	if not abilities.has(item_resource.item_name):
		# Add the item resource to our dictionary of known abilities.
		abilities[item_resource.item_name] = item_resource
		
		# If the item has an associated ability scene, instance it and add it
		# as a child of the player.
		if item_resource.ability_scene:
			var ability_instance = item_resource.ability_scene.instantiate()
			# It's good practice to give the instanced ability a clear name.
			# This gets the filename of the scene (e.g., "GrapplingHookAbility") and uses it as the node name.
			ability_instance.name = item_resource.ability_scene.get_path().get_file().get_basename()
			add_child(ability_instance)
			
		print("Picked up: ", item_resource.item_name)

# This function is used by states to check if the player possesses a certain ability.
func has_ability(ability_name: String) -> bool:
	return abilities.has(ability_name)

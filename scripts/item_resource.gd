class_name ItemResource
extends Resource

@export var item_name: String
@export var item_description: String
@export var pickup_texture: Texture2D
# This is the key: a scene that holds the item's logic!
@export var ability_scene: PackedScene

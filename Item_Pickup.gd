extends Area2D

@export var item: ItemResource

func _ready():
	if item:
		$Sprite2D.texture = item.pickup_texture

func _on_body_entered(body):
	# Check if it's the player and if the player can collect items
	if body.has_method("add_item"):
		body.add_item(item)
		queue_free() # Disappear after pickup

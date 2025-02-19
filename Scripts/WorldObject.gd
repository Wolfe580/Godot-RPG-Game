class_name WorldObject
extends Node3D 

@export var item_data: InventoryItem 
@export var pickup_range: float = 2.0 

func _ready() -> void:
	if item_data:
		$Sprite3D.texture = item_data.icon
		$CollisionShape3D.shape.radius = pickup_range

func interact(player: Node) -> void:
	if player.has_method("pick_up_item"):
		player.pick_up_item(item_data)
		queue_free()

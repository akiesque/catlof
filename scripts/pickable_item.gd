extends Area2D
class_name GroundItem

@export var item_data: BagItem 
@onready var icon: Sprite2D = $Icon

func _ready() -> void:
	if item_data and icon:
		icon.texture = item_data.pickup 

func collect(inventory) -> void:
	if item_data and inventory:
		print("Picked up: ", item_data.name)
		
		if inventory.has_method("add_item"):
			inventory.add_item(item_data)
		else:
			inventory.items.append(item_data)
			
	queue_free()

extends Node

@onready var inventory_data: Bag = preload("res://assets/bag/playerbag.tres")

func give_item(item_path: String) -> void:
	var item_to_add = load(item_path)
	if item_to_add is BagItem:
		inventory_data.add_item(item_to_add)
	else:
		print("Error: Path is not a BagItem resource")
		

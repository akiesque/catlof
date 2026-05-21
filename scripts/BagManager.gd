extends Node

@onready var inventory_data: Bag = preload("res://assets/bag/playerbag.tres")

func give_item(item_path: String) -> void:
	var item_to_add = load(item_path)
	if item_to_add is BagItem:
		inventory_data.add_item(item_to_add)
	else:
		print("Error: Path is not a BagItem resource")
		
func take_item(item_path: String) -> void:
	var item_res = load(item_path)
	if item_res is BagItem:
		inventory_data.remove_item(item_res)
	else:
		print("Error: Path is not a BagItem resource")
		
# Usage:		
#if BagManager.has_item("Old Key")
	#NPC: Oh, you found it!
	#do BagManager.take_item(...)
#else
	#NPC: Come back when you find my key.

func has_item(item_name: String) -> bool:
	for item in inventory_data.items:
		if item != null and item.name == item_name:
			return true
	return false


		

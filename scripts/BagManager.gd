extends Node

@onready var inventory_data: Bag = preload("res://assets/bag/playerbag.tres")

signal inventory_changed

func _ready():
	inventory_data.inventory_updated.connect(func(): inventory_changed.emit())

func give_item(item_path: String) -> void:
	var item_to_add = load(item_path)
	if item_to_add is BagItem:
		inventory_data.add_item(item_to_add)
	else:
		print("Error: Path is not a BagItem resource")
	inventory_changed.emit()
		
func take_item(item_path: String) -> void:
	var item_res = load(item_path)
	if item_res is BagItem:
		inventory_data.remove_item(item_res)
	else:
		print("Error: Path is not a BagItem resource")
	inventory_changed.emit()
		
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
	
func get_item_count(item_name: String) -> int:
	for item in inventory_data.items:
		if item != null and item.name == item_name:
			return item.quantity
	return 0

func remove_item_by_name(item_name: String, amount: int = 1) -> void:
	for item in inventory_data.items:
		if item != null and item.name == item_name:
			item.quantity -= amount
			if item.quantity <= 0:
				inventory_data.items[inventory_data.items.find(item)] = null
				print("Removed last ", item_name)
			else:
				print("Removed ", amount, "x ", item_name, ". Remaining: ", item.quantity)
			inventory_data.inventory_updated.emit()
			return
	print("Item not found: ", item_name)

func add_item_by_path(item_path: String, amount: int = 1) -> void:
	for i in range(amount):
		give_item(item_path)

		

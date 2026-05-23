extends Resource
class_name Bag

@export var items: Array[BagItem]
signal inventory_updated 

func add_item(new_item: BagItem) -> void:
	if new_item == null: return
	for item in items:
		if item != null and item.name == new_item.name:
			item.quantity += 1
			print("Stacked ", item.name, ". New quantity: ", item.quantity)
			inventory_updated.emit()  
			return
			
	var item_spawn = new_item.duplicate()
	item_spawn.quantity = 1
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item_spawn
			print("Filled an empty slot with: ", item_spawn.name)
			inventory_updated.emit()  # ADD THIS
			return
	items.append(item_spawn)
	print("Bag expanded. Added to end: ", item_spawn.name)
	inventory_updated.emit()
	
func remove_item(item_to_remove: BagItem) -> void:
	if item_to_remove == null: return
	
	for i in range(items.size()):
		var item = items[i]
		if item != null and item.name == item_to_remove.name:
			item.quantity -= 1
			
			if item.quantity <= 0:
				items[i] = null 
				print("Removed last ", item.name)
			else:
				print("Removed one ", item.name, ". Remaining: ", item.quantity)
			
			inventory_updated.emit() # Refresh UI
			return
	
	print("Item not found in bag: ", item_to_remove.name)

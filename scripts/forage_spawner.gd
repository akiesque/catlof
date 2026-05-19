extends ReferenceRect

# 1. Load your base GroundItem scene
const GROUND_ITEM_SCENE = preload("res://scenes/Pickable_Item.tscn")

# 2. Add an array in the inspector where you can drop different item resource types
@export var possible_items: Array[BagItem] = []

# 3. How many items should spawn maximum in this zone?
@export var max_items_to_spawn: int = 3

func _ready() -> void:
	# For testing: Spawn items immediately when entering the room
	spawn_multiple_items(max_items_to_spawn)
	
	# Optional: Hide the red editor border line during gameplay
	border_color = Color(0, 0, 0, 0)

func spawn_single_item() -> void:
	if possible_items.size() == 0:
		print("Spawner Warning: No items assigned to pool!")
		return
		
	# Pick a random item from our pool
	var random_item_data = possible_items[randi() % possible_items.size()]
	var random_x = randf_range(0, size.x)
	
	var fixed_y = size.y 
	
	# Create the ground item instance
	var item_instance = GROUND_ITEM_SCENE.instantiate() as GroundItem
	
	# Add it to the level scene tree
	get_parent().add_child.call_deferred(item_instance)
	
	# Set its data and absolute world coordinates
	item_instance.item_data = random_item_data
	item_instance.global_position = global_position + Vector2(random_x, fixed_y)

func spawn_multiple_items(count: int) -> void:
	for i in range(count):
		spawn_single_item()

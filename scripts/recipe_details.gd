extends Control

@onready var recipe_name: Label = $MarginContainer/HBoxContainer/VBoxContainer/RecipeName
@onready var description: Label = $MarginContainer/HBoxContainer/VBoxContainer/Description
@onready var btn: TextureButton = $MarginContainer/HBoxContainer/Button

var current_data: Dictionary = {}

func _ready():
	btn.pressed.connect(_on_make_button_pressed)

func show_recipe(data: Dictionary):
	current_data = data
	recipe_name.text = data["name"]
	description.text = data.get("description", "No description.")
	
	var can_make = true
	
	for ing in data["ingredients"]:
		var player_has = BagManager.get_item_count(ing["name"])
		print("Ingredient: ", ing["name"], " | need: ", ing["quantity"], " | have: ", player_has)  # ← add this
		if player_has < ing["quantity"]:
			can_make = false
			break
	
	print("Can make: ", can_make)  # ← and this
	btn.disabled = !can_make
	print("Button disabled set to: ", btn.disabled, " | btn node: ", btn)
	
func _on_make_button_pressed():
	print("Make button pressed! current_data: ", current_data)
	var possible_counts = []
	for ing in current_data["ingredients"]:
		var count = BagManager.get_item_count(ing["name"]) / ing["quantity"]
		print("Possible count for ", ing["name"], ": ", count)
		possible_counts.append(count)
	
	var max_can_make = possible_counts.min()
	print("Max can make: ", max_can_make)
	var main_ui = get_tree().root.find_child("CraftCookUI", true, false)
	
	if max_can_make > 1:
		main_ui.set_buttons_disabled(true)
		main_ui.quantity_craft.open(current_data)
	else:
		print("Calling do_craft!")
		main_ui.do_craft(current_data, 1)

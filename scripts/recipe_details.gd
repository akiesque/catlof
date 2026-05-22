extends Control

@onready var recipe_name: Label = $MarginContainer/HBoxContainer/VBoxContainer/RecipeName
@onready var description: Label = $MarginContainer/HBoxContainer/VBoxContainer/Description
@onready var btn: TextureButton = $MarginContainer/HBoxContainer/Button

var current_data: Dictionary = {}

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
	var possible_counts = []
	for ing in current_data["ingredients"]:
		possible_counts.append(BagManager.get_item_count(ing["name"]) / ing["quantity"])
	
	var max_can_make = possible_counts.min()
	
	if max_can_make > 1:
		var main_ui = get_tree().root.find_child("CraftCookUI", true, false)
		main_ui.quantity_craft.open(current_data)
	else:
		var main_ui = get_tree().root.find_child("CraftCookUI", true, false)
		main_ui.do_craft(current_data, 1)

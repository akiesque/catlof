extends Control

signal craft_confirmed(quantity: int)

@onready var minus: TextureButton = $NinePatchRect/VBoxContainer/HBoxContainer/Minus
@onready var to_make: Label = $NinePatchRect/VBoxContainer/HBoxContainer/ToMake
@onready var plus: TextureButton = $NinePatchRect/VBoxContainer/HBoxContainer/Plus


var current_amount: int = 1
var max_amount: int = 1

func open(recipe_data: Dictionary):
	# Calculate how many they can actually make
	var possible_counts = []
	for ing in recipe_data["ingredients"]:
		var player_has = BagManager.get_item_count(ing["name"])
		possible_counts.append(player_has / ing["quantity"])
	
	max_amount = possible_counts.min()
	current_amount = 1
	update_ui()
	show()

func update_ui():
	to_make.text = str(current_amount)
	
	# Disable minus if at 1
	minus.disabled = (current_amount <= 1)
	# Disable plus if at max
	plus.disabled = (current_amount >= max_amount)

func _on_plus_pressed():
	if current_amount < max_amount:
		current_amount += 1
		update_ui()

func _on_minus_pressed():
	if current_amount > 1:
		current_amount -= 1
		update_ui()

func _on_ok_button_pressed():
	craft_confirmed.emit(current_amount)
	hide()

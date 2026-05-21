extends Control

@onready var recipe_name: Label = $HBoxContainer/VBoxContainer/RecipeName
@onready var description: Label = $HBoxContainer/VBoxContainer/Description
@onready var btn: Button = $HBoxContainer/Button

var current_data = RecipeBook.get_current_recipes()

func show_recipe(data: Dictionary):
	current_data = data
	recipe_name.text = data["name"]
	description.text = data.get("description", "No description.")
	show()
	# Tween slide in from right
	position.x = 300  # offscreen
	var tween = create_tween()
	tween.tween_property(self, "position:x", 0.0, 0.2)
	btn.grab_focus()

func _on_make_button_pressed():
	print("Crafting: ", current_data["name"])
	# hook into your crafting logic here!

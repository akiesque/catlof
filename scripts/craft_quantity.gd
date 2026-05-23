extends Control

@onready var plus: TextureButton = $NinePatchRect/VBoxContainer/HBoxContainer/Plus
@onready var minus: TextureButton = $NinePatchRect/VBoxContainer/HBoxContainer/Minus
@onready var to_make: Label = $NinePatchRect/VBoxContainer/HBoxContainer/ToMake
@onready var btn: Button = $NinePatchRect/VBoxContainer/Button
@onready var ok: Button = $NinePatchRect/VBoxContainer/Button


signal craft_confirmed(quantity: int)


var current_amount: int = 1
var max_amount: int = 1

func _ready() -> void:
	self.hide()
	plus.pressed.connect(_on_plus_pressed)
	minus.pressed.connect(_on_minus_pressed)
	ok.pressed.connect(_on_ok_button_pressed)
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func open(recipe_data: Dictionary):
	var possible_counts = []
	for ing in recipe_data["ingredients"]:
		var player_has = BagManager.get_item_count(ing["name"])
		var count = player_has / ing["quantity"]
		print("CraftQuantity sees: ", ing["name"], " player_has=", player_has, " count=", count)
		possible_counts.append(count)
	print("possible_counts array: ", possible_counts)
	max_amount = possible_counts.min()
	print("max_amount set to: ", max_amount)
	
	# Safety check if recipe has no ingredients or something went wrong
	max_amount = possible_counts.min() if possible_counts.size() > 0 else 1
	current_amount = 1
	
	update_ui()
	self.show() 


func update_ui():
	print("UI updated. Plus disabled: ", plus.disabled, " | Label says: ", current_amount)
	to_make.text = str(current_amount)
	minus.disabled = (current_amount <= 1)
	plus.disabled = (current_amount >= max_amount)

func _on_plus_pressed():
	print("!!! PLUS BUTTON PHYSICALLY CLICKED !!!")
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

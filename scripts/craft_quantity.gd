extends Control


@onready var plus: TextureButton = $NinePatchRect/VBoxContainer/HBoxContainer/Plus
@onready var minus: TextureButton = $NinePatchRect/VBoxContainer/HBoxContainer/Minus
@onready var to_make: Label = $NinePatchRect/VBoxContainer/HBoxContainer/ToMake
@onready var btn: Button = $NinePatchRect/VBoxContainer/Button


signal craft_confirmed(quantity: int)


var current_amount: int = 1
var max_amount: int = 1

func _ready() -> void:
	self.hide()
	plus.pressed.connect(_on_plus_pressed)
	minus.pressed.connect(_on_minus_pressed)
	var ok = find_child("Button", true, false)
	if ok:
		ok.pressed.connect(_on_ok_button_pressed)
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func open(recipe_data: Dictionary):
	print("MAX AMOUNT CALCULATED: ", max_amount)
	var possible_counts = []
	for ing in recipe_data["ingredients"]:
		var player_has = BagManager.get_item_count(ing["name"])
		# Use floor division to get whole units
		possible_counts.append(player_has / ing["quantity"])
	
	# Safety check if recipe has no ingredients or something went wrong
	max_amount = possible_counts.min() if possible_counts.size() > 0 else 1
	current_amount = 1
	
	self.show() 


#func update_ui():
	#to_make.text = str(current_amount)
	#minus.disabled = (current_amount <= 1)
	#plus.disabled = (current_amount >= max_amount)

func _on_plus_pressed():
	if current_amount < max_amount:
		current_amount += 1
		#update_ui()

func _on_minus_pressed():
	if current_amount > 1:
		current_amount -= 1
		#update_ui()

func _on_ok_button_pressed():
	craft_confirmed.emit(current_amount)
	hide()

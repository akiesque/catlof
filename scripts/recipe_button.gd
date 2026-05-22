extends Control

@onready var btn: Button = $Button
@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var ingredients_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer
@onready var margin: MarginContainer = $MarginContainer
const INGREDIENT_SLOT = preload("res://scenes/IngredientSlot.tscn")
@onready var arrow: TextureRect = $Arrow
@onready var eff: AnimationPlayer = $Eff

var base_x: float = -9999
var base_arrow_x: float = -9999

var current_ingredients_data = []

func _ready():
	btn.focus_entered.connect(_on_focus)
	btn.focus_exited.connect(_on_unfocus)
	arrow.modulate.a = 0.0 
	BagManager.inventory_changed.connect(refresh_ingredients)
	
func _input(event: InputEvent):
	if not btn.has_focus():
		return
	if event.is_action_pressed("interact"):
		btn.emit_signal("pressed")
		get_viewport().set_input_as_handled()

func _on_focus():
	if base_x == -9999:
		base_x = margin.position.x
	if base_arrow_x == -9999:
		base_arrow_x = arrow.position.x
	eff.play("bouncey")
	label.add_theme_color_override("font_color", Color("313039"))
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(margin, "position:x", base_x + 20, 0.1)

	tween.tween_property(arrow, "modulate:a", 1.0, 0.1)
	tween.tween_property(arrow, "position:x", base_arrow_x, 0.1) 

func _on_unfocus():
	eff.stop()
	label.add_theme_color_override("font_color", Color.WHITE)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(margin, "position:x", base_x, 0.1)
	
	tween.tween_property(arrow, "modulate:a", 0.0, 0.1)
	tween.tween_property(arrow, "position:x", base_arrow_x + -10.0, 0.1)  


func get_button() -> Button:
	return btn

func populate_ingredients(ingredients: Array):
	current_ingredients_data = ingredients
	refresh_ingredients()
	
func refresh_ingredients():
	for child in ingredients_container.get_children():
		child.free()
	for ing in current_ingredients_data:
		var slot = INGREDIENT_SLOT.instantiate()
		ingredients_container.add_child(slot)
		
		var icon = slot.find_child("Ingredients", true, false)
		if icon and ing.has("icon"):
			icon.texture = load(ing["icon"])
			
		var quantity = slot.find_child("Quantity", true, false)
		if quantity:
			if quantity.label_settings:
				quantity.label_settings = quantity.label_settings.duplicate()
			
			quantity.text = str(ing["quantity"])
			
			var player_count = BagManager.get_item_count(ing["name"])
			print("Checking ingredient: '", ing["name"], "' | player has: ", player_count, " | needs: ", ing["quantity"])
			var has_enough = player_count >= ing["quantity"]
			
			if not has_enough:
				quantity.label_settings.font_color = Color('b92734') # RED
			else:
					quantity.label_settings.font_color = Color('6b6184')

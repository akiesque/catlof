extends Control

@onready var layer: CanvasLayer = $CanvasLayer
@onready var container: VBoxContainer = $CanvasLayer/SidePanelArea/Panel/ScrollContainer/VBoxContainer
@onready var recipe_details: Control = $CanvasLayer/RecipeDetails
@onready var quantity_craft: Control = $CanvasLayer/CraftQuantity

const RECIPE_DETAILS = preload("uid://bxd3eq5r50ume")
const RECIPE_BUTTON = preload("uid://dgsj4t75dxt18")

var is_open := false
var open_detail_panel = null

func _ready() -> void:
	layer.visible = false
	recipe_details.hide()
	quantity_craft.craft_confirmed.connect(_on_quantity_confirmed)
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	
func _on_quantity_confirmed(amount: int):
	set_buttons_disabled(false) 
	if open_detail_panel:
		var data = open_detail_panel.current_data
		do_craft(data, amount)

func do_craft(recipe_data: Dictionary, craft_count: int):
	open_detail_panel = null
	for ing in recipe_data["ingredients"]:
		BagManager.remove_item_by_name(ing["name"], ing["quantity"] * craft_count)
	print("result_path exists: ", recipe_data.has("result_path"))  # ← add
	if recipe_data.has("result_path"):
		print("Adding: ", recipe_data["result_path"])  # ← add
		BagManager.add_item_by_path(recipe_data["result_path"], craft_count)
	await populate_recipes()
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if UIManager.is_blocked():
		return
	# DEBUG - remove before release
	if event.is_action_pressed("Test"):
		if is_open:
			close_ui()
		else:
			open_ui()
		return

	if not is_open:
		return

	if quantity_craft.visible:
		# Only allow closing quantity popup with Q
		if event is InputEventKey and event.is_pressed() and not event.is_echo():
			if event.physical_keycode == KEY_Q:
				quantity_craft.hide()
				set_buttons_disabled(false)
				get_viewport().set_input_as_handled()
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.physical_keycode:
			KEY_Q:
				if open_detail_panel:
					_close_detail(open_detail_panel)
					open_detail_panel = null
				else:
					close_ui()
				get_viewport().set_input_as_handled()
				
func open_ui():
	UIManager.set_open("CraftCookUI", true)
	is_open = true
	layer.visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	populate_recipes()

func close_ui():
	UIManager.set_open("CraftCookUI", false)
	is_open = false
	open_detail_panel = null
	layer.visible = false
	get_tree().paused = false
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func populate_recipes():
	for child in container.get_children():
		child.queue_free()
	await get_tree().process_frame
	var recipes = RecipeBook.get_current_recipes()
	for data in recipes:
		var btn_instance = RECIPE_BUTTON.instantiate()
		container.add_child(btn_instance)

		var detail = RECIPE_DETAILS.instantiate()
		container.add_child(detail)
		detail.process_mode = Node.PROCESS_MODE_ALWAYS
		detail.hide()
		detail.custom_minimum_size.y = 0
		
		var make_btn = detail.find_child("Button", true, false)
		if make_btn:
			make_btn.process_mode = Node.PROCESS_MODE_ALWAYS

		var label = btn_instance.find_child("Label", true, false)
		if label:
			label.text = data["name"]
		if btn_instance.has_method("populate_ingredients"):
			btn_instance.populate_ingredients(data["ingredients"])

		var icon_node = btn_instance.find_child("Icon", true, false)
		if icon_node and data.has("icon"):
			var tex = load(data["icon"])
			if icon_node is TextureRect:
				icon_node.texture = tex

		btn_instance.pressed.connect(_on_recipe_selected.bind(data, detail, btn_instance))

func _on_recipe_selected(data: Dictionary, detail_panel: Control, _btn_instance: Button):
	if open_detail_panel and open_detail_panel != detail_panel:
		_close_detail(open_detail_panel)
	if detail_panel.visible:
		_close_detail(detail_panel)
		open_detail_panel = null
	else:
		_open_detail(detail_panel, data)
		open_detail_panel = detail_panel

func _open_detail(panel: Control, data: Dictionary):
	panel.modulate.a = 0.0
	panel.show()
	if panel.has_method("show_recipe"):
		panel.show_recipe(data)
	panel.custom_minimum_size.y = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "custom_minimum_size:y", 120.0, 0.2)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)

func _close_detail(panel: Control):
	if not is_instance_valid(panel):
		return
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "custom_minimum_size:y", 0.0, 0.15)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	await get_tree().create_timer(0.15).timeout
	if is_instance_valid(panel):
		panel.hide()

func set_buttons_disabled(disabled: bool) -> void:
	var buttons = container.get_children().filter(func(c): return c is Button)
	for btn in buttons:
		btn.disabled = disabled
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE if disabled else Control.MOUSE_FILTER_STOP

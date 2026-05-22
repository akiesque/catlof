extends Control

@onready var layer: CanvasLayer = $CanvasLayer
@onready var container: VBoxContainer = $CanvasLayer/SidePanelArea/Panel/ScrollContainer/VBoxContainer
@onready var recipe_details: Control = $CanvasLayer/RecipeDetails

@onready var quantity_craft: Control = $CanvasLayer/CraftQuantity

const RECIPE_DETAILS = preload("uid://bxd3eq5r50ume")
const RECIPE_BUTTON = preload("uid://dgsj4t75dxt18")

var is_open := false
var current_index := -1 
var open_detail_panel = null  
var detail_focused := false

func _ready() -> void:
	layer.visible = false
	recipe_details.hide()
	quantity_craft.craft_confirmed.connect(_on_quantity_confirmed)
	
func _on_quantity_confirmed(amount: int):
	# We need to know WHICH recipe was active. 
	# You can store it in a variable when the popup opens.
	if open_detail_panel:
		var data = open_detail_panel.current_data 
		do_craft(data, amount)

func do_craft(recipe_data: Dictionary, craft_count: int):
	# Spend ingredients
	for ing in recipe_data["ingredients"]:
		BagManager.remove_item_by_name(ing["name"], ing["quantity"] * craft_count)
	
	# Give result — add "result_path" to your recipe data!
	if recipe_data.has("result_path"):
		BagManager.add_item_by_path(recipe_data["result_path"], craft_count)
	
	print("Crafted ", craft_count, "x ", recipe_data["name"])
	populate_recipes()

func _input(event: InputEvent) -> void:
	# DEBUG - remove before release
	if event.is_action_pressed("Test"):
		if is_open:
			close_ui()
		else:
			open_ui()
		return

	if not is_open:
		return
	
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		return
		
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.physical_keycode:
			KEY_Q:
				if detail_focused:
					detail_focused = false
					var buttons = container.get_children().filter(func(c): return c.has_method("get_button"))
					if current_index < buttons.size():
						buttons[current_index].get_button().grab_focus()
				elif open_detail_panel:
					_close_detail(open_detail_panel)
					open_detail_panel = null
				else:
					close_ui()
				get_viewport().set_input_as_handled()
			KEY_E: 
				if detail_focused:
					print("detail_focused: ", detail_focused) 
					if open_detail_panel:
						var make_btn = open_detail_panel.find_child("Button", true, false)
						if make_btn:
							if make_btn.disabled:
								print("BZZZT! Not enough ingredients.")
								# AudioManager.play_sfx("error_sound") # Add your sound logic here
								make_btn.release_focus() 
							else:
								make_btn.emit_signal("pressed")
								print("Emitting pressed!")
				elif current_index != -1:
					var buttons = container.get_children().filter(func(c): return c.has_method("get_button"))
					if current_index < buttons.size():
						var recipe_btn = buttons[current_index].get_button()
						if recipe_btn.disabled:
							# Optional: play sound here too if the recipe row is disabled
							pass
						else:
							recipe_btn.emit_signal("pressed")
				get_viewport().set_input_as_handled()
			KEY_UP:
				if detail_focused:
					detail_focused = false
					_close_detail(open_detail_panel)
					open_detail_panel = null
					_navigate(KEY_UP)  
				else:
					_navigate(KEY_UP)
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				if detail_focused:
					detail_focused = false
					_close_detail(open_detail_panel)
					open_detail_panel = null
					_navigate(KEY_DOWN)  
				elif open_detail_panel:
					detail_focused = true
					var make_btn = open_detail_panel.find_child("Button", true, false)
					if make_btn:
						make_btn.grab_focus()
				else:
					_navigate(KEY_DOWN)
				get_viewport().set_input_as_handled()

func _navigate(key: int) -> void:
	var buttons = container.get_children().filter(func(c): return c.has_method("get_button"))
	var count = buttons.size()
	if count == 0:
		return
	if current_index == -1:
		current_index = 0 if key == KEY_DOWN else count - 1
	else:
		if key == KEY_DOWN:
			current_index = (current_index + 1) % count
		else:
			current_index = (current_index - 1 + count) % count

	var target_instance = buttons[current_index]
	var btn = target_instance.get_button()
	if btn:
		btn.grab_focus()
		await get_tree().process_frame
		container.get_parent().ensure_control_visible(target_instance)

func open_ui():
	is_open = true
	current_index = -1 
	layer.visible = true
	get_tree().paused = true
	populate_recipes()
	show()

func close_ui():
	is_open = false
	current_index = -1
	hide()
	layer.visible = false
	get_tree().paused = false

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
		detail.hide()
		detail.custom_minimum_size.y = 0
		detail.set_deferred("size", Vector2(detail.size.x, 0))

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

		var actual_button = btn_instance.get_button() if btn_instance.has_method("get_button") else btn_instance.find_child("Button", true, false)
		if actual_button:
			actual_button.pressed.connect(_on_recipe_selected.bind(data, detail, btn_instance))

func _on_recipe_selected(data: Dictionary, detail_panel: Control, _btn_instance: Control):
	# Close previously open panel
	if open_detail_panel and open_detail_panel != detail_panel:
		_close_detail(open_detail_panel)
	
	# Toggle
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
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "custom_minimum_size:y", 0.0, 0.15)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	# Wait for the longest tween to finish
	await get_tree().create_timer(0.15).timeout
	panel.hide()
	

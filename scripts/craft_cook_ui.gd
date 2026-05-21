extends Control

@onready var layer: CanvasLayer = $CanvasLayer
@onready var container: VBoxContainer = $CanvasLayer/SidePanelArea/Panel/ScrollContainer/VBoxContainer
@onready var recipe_details: Control = $CanvasLayer/RecipeDetails

const RECIPE_DETAILS = preload("uid://bxd3eq5r50ume")
const RECIPE_BUTTON = preload("uid://dgsj4t75dxt18")

var is_open := false
var current_index := -1  # -1 means no focus
var open_detail_panel = null  # track which panel is open

func _ready() -> void:
	layer.visible = false
	recipe_details.hide()

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
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.physical_keycode:
			KEY_Q:
				if open_detail_panel:
					_close_detail(open_detail_panel)
					open_detail_panel = null
				else:
					close_ui()
				get_viewport().set_input_as_handled()
			KEY_E:
				get_viewport().set_input_as_handled()
			KEY_UP, KEY_DOWN:
				_navigate(event.physical_keycode)
				get_viewport().set_input_as_handled()

func _navigate(key: int) -> void:
	var count = container.get_child_count()
	if count == 0:
		return
	if current_index == -1:
		current_index = 0 if key == KEY_DOWN else count - 1
	else:
		if key == KEY_DOWN:
			current_index = (current_index + 1) % count
		else:
			current_index = (current_index - 1 + count) % count

	var target_instance = container.get_child(current_index)
	var btn = target_instance.get_button() if target_instance.has_method("get_button") else target_instance.find_child("Button", true, false)
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
		# Add the recipe button
		var btn_instance = RECIPE_BUTTON.instantiate()
		container.add_child(btn_instance)
		
		# Add its detail panel RIGHT after, hidden
		var detail = RECIPE_DETAILS.instantiate()
		container.add_child(detail)
		detail.hide()
		detail.custom_minimum_size.y = 0

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
			# Pass BOTH data and detail panel to the button
			actual_button.pressed.connect(_on_recipe_selected.bind(data, detail, btn_instance))



func _on_recipe_selected(data: Dictionary, detail_panel: Control, btn_instance: Control):
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
	panel.show()
	var description = panel.find_child("Description", true, false)
	if description:
		description.text = data.get("description", "No description.")
	# Tween height open
	panel.custom_minimum_size.y = 0
	var tween = create_tween()
	tween.tween_property(panel, "custom_minimum_size:y", 80.0, 0.15)
func _close_detail(panel: Control):
	var tween = create_tween()
	tween.tween_property(panel, "custom_minimum_size:y", 0.0, 0.15)
	await tween.finished
	panel.hide()

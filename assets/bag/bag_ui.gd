extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var layer: CanvasLayer = $CanvasLayer
@onready var book_bg: TextureRect = $CanvasLayer/BookBG
@onready var tab_overlay: TextureRect = $CanvasLayer/BookBG/TabSheetOverlay

#PAGES SECTION
@onready var pages = [
	$CanvasLayer/BookBG/TabPages/Bag,
	$CanvasLayer/BookBG/TabPages/Map,
	$CanvasLayer/BookBG/TabPages/Char,
	$CanvasLayer/BookBG/TabPages/Settings
]

const BOOK_SHEETS = [
	preload("res://assets/bag/bag_tab.png"),
	preload("res://assets/bag/map_tab.png"),
	preload("res://assets/bag/chara_tab.png"),
	preload("res://assets/bag/settings_tab.png")
]

var is_transitioning: bool = false

#SLOTS FOR BAG UI
const SLOT_SCENE = preload("res://assets/bag/BagSlot.tscn")
@onready var inventory_data = preload("res://assets/bag/playerbag.tres")

@onready var item_label: Label = $CanvasLayer/BookBG/TabPages/Bag/VBoxContainer/ItemLabel
@onready var item_desc: RichTextLabel = $CanvasLayer/BookBG/TabPages/Bag/VBoxContainer/ItemDesc
@onready var grid_container: GridContainer = $CanvasLayer/BookBG/TabPages/Bag/GridContainer


var is_open: bool = false
var current_tab: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	book_bg.process_mode = Node.PROCESS_MODE_ALWAYS
	tab_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	
	layer.visible = false
	close()

func _input(event: InputEvent) -> void:
	if is_transitioning:
		return
	if event.is_action_pressed("bag_open"):
		if is_open:
			close()
			get_viewport().set_input_as_handled()
		else:
			if not is_transition_playing():
				open()
				get_viewport().set_input_as_handled()
		return

	if is_open and event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_Q:
			switch_to_tab(posmod(current_tab - 1, pages.size()))
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E:
			switch_to_tab(posmod(current_tab + 1, pages.size()))
			get_viewport().set_input_as_handled()

func open() -> void:
	if GameManager.is_dialogue_active:
		return
	is_transitioning = true
	layer.visible = true 
	is_open = true
	get_tree().paused = true 
	anim.play("open_inventory")
	populate_slots()
	switch_to_tab(0)
	
	await anim.animation_finished
	is_transitioning = false
	
func populate_slots() -> void:
	if not grid_container: return
	
	for child in grid_container.get_children():
		child.queue_free()
		
	var item_list = []
	if inventory_data.get("items"):
		item_list = inventory_data.items
	elif inventory_data is Array:
		item_list = inventory_data
		
	update_description_panel(null)
		
	for i in range(item_list.size()):
		var slot_instance = SLOT_SCENE.instantiate()
		grid_container.add_child(slot_instance)
		slot_instance.display_item(item_list[i])
		
		slot_instance.item_hovered.connect(update_description_panel)
		slot_instance.focus_mode = Control.FOCUS_ALL
		slot_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		
		if i == 0:
			slot_instance.force_focus()

func update_description_panel(item: BagItem) -> void:
	if item == null:
		if item_label: item_label.text = ""
		if item_desc: item_desc.text = ""
	else:
		if item_label: item_label.text = item.name
		if item_desc: item_desc.text = item.desc

func close() -> void:
	is_transitioning = true
	is_open = false
	if anim and layer and anim.has_animation("open_inventory") and layer.visible:
		anim.play("close_inventory")
		await anim.animation_finished

	if layer:
		layer.visible = false
	get_tree().paused = false
	
	is_transitioning = false

func switch_to_tab(index: int) -> void:
	current_tab = index
	
	if tab_overlay and BOOK_SHEETS[index]:
		tab_overlay.texture = BOOK_SHEETS[index]
	
	for i in range(pages.size()):
		if pages[i]:
			pages[i].visible = (i == index)
			if i == index:
				pages[i].show()
				
				if i == 0 and grid_container and grid_container.get_child_count() > 0:
					grid_container.get_child(0).force_focus()
			else:
				pages[i].hide()
				
	print("Switched UI to Tab Index: ", index)

func is_transition_playing() -> bool:
	if Transition and Transition.anim_player and Transition.anim_player.is_playing():
		return true
	return false

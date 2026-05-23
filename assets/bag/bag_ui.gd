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

var selected_item: BagItem = null

const BOOK_SHEETS = [
	preload("res://assets/bag/bag_tab.png"),
	preload("res://assets/bag/map_tab.png"),
	preload("res://assets/bag/chara_tab.png"),
	preload("res://assets/bag/settings_tab.png")
]

var focused_slot: int = 0

#SLOTS FOR BAG UI
const SLOT_SCENE = preload("res://assets/bag/BagSlot.tscn")
@onready var inventory_data = preload("res://assets/bag/playerbag.tres")

@onready var item_label: Label = $CanvasLayer/BookBG/TabPages/Bag/VBoxContainer/LabelContainer/ItemLabel
@onready var item_desc: RichTextLabel = $CanvasLayer/BookBG/TabPages/Bag/VBoxContainer/MarginContainer/ItemDesc
@onready var grid_container: GridContainer = $CanvasLayer/BookBG/TabPages/Bag/GridContainer

var is_open: bool = false
var current_tab: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	book_bg.process_mode = Node.PROCESS_MODE_ALWAYS
	tab_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	inventory_data.inventory_updated.connect(populate_slots) 
	
	layer.visible = false
	close()

func _input(event: InputEvent) -> void:
	if UIManager.is_blocked():
		return
	if not GameManager.unlocked_book:
		return
	if event.is_action_pressed("bag_open"):
		if is_open: close()
		else: open()
		get_viewport().set_input_as_handled()
		return
	if not is_open:
		return
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.physical_keycode:
			KEY_Q:
				switch_to_tab(posmod(current_tab - 1, pages.size()))
				get_viewport().set_input_as_handled()
			KEY_E:
				switch_to_tab(posmod(current_tab + 1, pages.size()))
				get_viewport().set_input_as_handled()

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		match event.physical_keycode:
			KEY_Q:
				switch_to_tab(posmod(current_tab - 1, pages.size()))
				get_viewport().set_input_as_handled()
			KEY_E:
				switch_to_tab(posmod(current_tab + 1, pages.size()))
				get_viewport().set_input_as_handled()
			
func navigate_slots(delta: int) -> void:
	if current_tab != 0: return  # only on bag tab
	var count = grid_container.get_child_count()
	if count == 0: return
	focused_slot = clamp(focused_slot + delta, 0, count - 1)
	grid_container.get_child(focused_slot).force_focus()
	
func _on_slot_hovered(item: BagItem) -> void:
	if selected_item:
		return
	update_description_panel(item)
	
func open() -> void:
	if UIManager.is_any_ui_open():
		return
	UIManager.set_open("BagUI", true)
	layer.visible = true
	is_open = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	anim.play("open_inventory")
	populate_slots()
	switch_to_tab(0)
	await anim.animation_finished
	
func populate_slots() -> void:
	if not grid_container:
		return
	
	for child in grid_container.get_children():
		child.queue_free()
	
	update_description_panel(null)
	
	const MAX_SLOTS = 6
	var items = inventory_data.items
	
	for i in range(MAX_SLOTS):
		var slot = SLOT_SCENE.instantiate()
		grid_container.add_child(slot)
		slot.process_mode = Node.PROCESS_MODE_ALWAYS 
		
		if i < items.size() and items[i] != null:
			slot.display_item(items[i])
		else:
			slot.display_item(null) 
		
		slot.item_hovered.connect(_on_slot_hovered)
		slot.item_clicked.connect(_on_slot_clicked) 

func _on_slot_clicked(item: BagItem) -> void:
	if selected_item == item:
		# Click same slot again to deselect
		selected_item = null
		update_description_panel(null)
	else:
		selected_item = item
		update_description_panel(item)

func update_description_panel(item: BagItem) -> void:
	if item == null:
		if item_label: item_label.text = ""
		if item_desc: item_desc.text = ""
	else:
		if item_label: item_label.text = item.name
		if item_desc: item_desc.text = item.desc
	
func close() -> void:
	UIManager.set_open("BagUI", false)
	is_open = false
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	selected_item = null 
	if anim and layer and anim.has_animation("open_inventory") and layer.visible:
		anim.play("close_inventory")
		await anim.animation_finished
	if layer:
		layer.visible = false
	get_tree().paused = false

func switch_to_tab(index: int) -> void:
	current_tab = index
	selected_item = null 

	if tab_overlay and BOOK_SHEETS[index]:
		tab_overlay.texture = BOOK_SHEETS[index]

	for i in range(pages.size()):
		if pages[i]:
			pages[i].visible = (i == index)
			if i == index:
				pages[i].show()
			else:
				pages[i].hide()
				

func is_transition_playing() -> bool:
	if Transition and Transition.anim_player and Transition.anim_player.is_playing():
		return true
	return false

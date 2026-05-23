# ItemSlot.gd
extends TextureButton

@onready var icon_rect: TextureRect = $ItemIcon
@onready var background_rect: TextureRect = $SlotBackground
@onready var quantity: Label = $Quantity

const TEXTURE_NORMAL = preload("res://assets/bag/bag_slot.png")
const TEXTURE_SELECTED = preload("res://assets/bag/bag_slot_focused.png")

var current_item: BagItem = null
var is_selected: bool = false

signal item_hovered(item: BagItem)
signal item_clicked(item: BagItem)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		get_viewport().set_input_as_handled()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	focus_entered.connect(_on_focused)
	mouse_entered.connect(_on_focused)
	focus_exited.connect(_on_focus_lost)
	mouse_exited.connect(_on_focus_lost)
	pressed.connect(func(): item_clicked.emit(current_item)) 
	if background_rect:
		background_rect.texture = TEXTURE_NORMAL

func set_selected(selected: bool) -> void:
	is_selected = selected
	if background_rect:
		background_rect.texture = TEXTURE_SELECTED if selected else TEXTURE_NORMAL


func force_focus() -> void:
	grab_focus()
	_on_focused()

func display_item(item: BagItem) -> void:
	current_item = item 
	
	if item:
		icon_rect.texture = item.texture
		icon_rect.show() 
		
		if item.quantity > 1:
			quantity.text = str(item.quantity)
			quantity.show()
		else:
			quantity.hide()
	else:
		icon_rect.texture = null
		icon_rect.hide()
		quantity.hide()

func _on_focused() -> void:
	item_hovered.emit(current_item)
	if not is_selected:  # only change texture if not selected
		if background_rect:
			background_rect.texture = TEXTURE_SELECTED

func _on_focus_lost() -> void:
	if not is_selected:  # only reset if not selected
		if background_rect:
			background_rect.texture = TEXTURE_NORMAL

# ItemSlot.gd
extends TextureButton

@onready var icon_rect: TextureRect = $ItemIcon
@onready var background_rect: TextureRect = $SlotBackground

const TEXTURE_NORMAL = preload("res://assets/bag/bag_slot.png")
const TEXTURE_SELECTED = preload("res://assets/bag/bag_slot_focused.png")

var current_item: BagItem = null
signal item_hovered(item: BagItem)

func _ready() -> void:
	focus_entered.connect(_on_focused)
	mouse_entered.connect(_on_focused)
	
	focus_exited.connect(_on_focus_lost)
	mouse_exited.connect(_on_focus_lost)
	
	if background_rect:
		background_rect.texture = TEXTURE_NORMAL

func force_focus() -> void:
	grab_focus()
	_on_focused()

func display_item(item_resource: BagItem) -> void:
	current_item = item_resource
	if current_item == null:
		icon_rect.texture = null
	else:
		icon_rect.texture = current_item.texture

func _on_focused() -> void:
	item_hovered.emit(current_item)
	if background_rect:
		background_rect.texture = TEXTURE_SELECTED

func _on_focus_lost() -> void:
	if background_rect:
		background_rect.texture = TEXTURE_NORMAL

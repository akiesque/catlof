extends Node2D

@export var needs_up_input: bool = true 
@export var dialogue: DialogueResource
@export var dialogue_start: String = "start"
@export_file("*.png") var bg_image: String

@onready var table: Sprite2D = $Table
@onready var interactable: Area2D = $Table/Interactable
const COOKINGTABLE = preload("uid://cpfk1xhuhbrmy")
const CRAFTINGTABLE = preload("uid://daw2nvwoji81r")
@onready var collision: CollisionShape2D = $Table/Interactable/CollisionShape2D

func _ready():
	interactable.interact = _on_interact
	if GameManager.unlock_crafting:
		table.texture = CRAFTINGTABLE
	else:
		table.texture = COOKINGTABLE
		
func _on_interact():
	if GameManager.is_dialogue_active:
		return
	if GameManager.is_true("interacted_table") and not GameManager.unlock_crafting:
		return
	if GameManager.unlock_crafting or GameManager.unlock_cooking:
		var a = get_tree().root.find_child("CraftCookUI", true, false)
		a.open_ui()
		return
		
	GameManager.next_dialogue_resource = dialogue
	GameManager.next_dialogue_start = dialogue_start
	GameManager.next_background_path = bg_image
	
	var ui = get_tree().root.find_child("ConversationUI", true, false)
	if ui:
		ui.start_ui()

func _process(_delta):
	var is_locked = GameManager.is_true("interacted_table") and not GameManager.unlock_crafting
	collision.set_deferred("disabled", is_locked)
	
	collision.visible = !is_locked

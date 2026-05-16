extends Node2D

@export var dialogue: DialogueResource
@export var dialogue_start: String = "start"
@export_file("*.png") var bg_image: String

@onready var interactable: Area2D = $Sprite2D/Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	GameManager.next_dialogue_resource = dialogue
	GameManager.next_dialogue_start = dialogue_start
	GameManager.next_background_path = bg_image
	
	var ui = get_tree().root.find_child("ConversationUI", true, false)
	if ui:
		ui.start_ui()

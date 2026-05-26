extends Node2D
@export var dialogue: DialogueResource
@export var dialogue_start: String = "start"
@export_file("*.png") var bg_image: String
@onready var collision: CollisionShape2D = $Sprite2D/Interactable/CollisionShape2D
@onready var interactable: Area2D = $Sprite2D/Interactable

# this one has specific conditions to be true + varying conditions.

func _ready() -> void:
	interactable.interact = _on_interact
	_update_collision()
	GameManager.flag_changed.connect(_update_collision)

func _update_collision() -> void:
	if dialogue_start == "tourists":
		var all_three_read = (
			GameManager.is_true("about_elementals") and
			GameManager.is_true("about_sirens") and
			GameManager.is_true("about_dragonborns")
		)
		collision.set_deferred("disabled", not all_three_read)
		interactable.set_deferred("monitoring", all_three_read)
		interactable.set_deferred("monitorable", all_three_read)
	else:
		collision.set_deferred("disabled", false)
		interactable.set_deferred("monitoring", true)
		interactable.set_deferred("monitorable", true)

func _on_interact():
	if GameManager.is_dialogue_active:
		return
	GameManager.next_dialogue_resource = dialogue
	GameManager.next_dialogue_start = dialogue_start
	GameManager.next_background_path = bg_image
	var ui = get_tree().root.find_child("ConversationUI", true, false)
	if ui:
		ui.start_ui()

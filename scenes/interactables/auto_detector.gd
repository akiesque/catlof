extends Area2D

@export var dialogue: DialogueResource
@export var dialogue_start: String = "start"
@export_file("*.png") var bg_image: String
@export var Pause_Music: bool = true 

@onready var interactable: Area2D = $"."

func _ready() -> void:
	# Connect the body_entered signal dynamically
	interactable.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# 1. Make sure it's actually the player walking into the zone
	# (Adjust "Player" to match your Player node's name or class)
	if not body.name == "Player": 
		return
		
	# 2. Check if a dialogue is already running so it doesn't double-trigger
	if GameManager.is_dialogue_active:
		return
	
	# 3. Trigger the conversation
	trigger_conversation()

func trigger_conversation() -> void:
	GameManager.next_dialogue_resource = dialogue
	GameManager.next_dialogue_start = dialogue_start
	GameManager.next_background_path = bg_image
	GameManager.set_pause_music(Pause_Music)

	var ui = get_tree().root.find_child("ConversationUI", true, false)
	if ui:
		ui.start_ui()
		
	# 4. Optional: Disable the area so it doesn't trigger again if they walk back into it
	queue_free()

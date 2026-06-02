extends Node2D 

@export var npc_id: String = "heine"
@export var real_name: String = "Heinester"
@export var dialogue: DialogueResource
@export var dialogue_start: String = "start"
@export_file("*.png") var bg_image: String

@onready var tag_ui: Control = $Tag
@onready var interact_zone: Area2D = $InteractZone # This has Interactable.gd attached

# Inside Heine's script

func _ready() -> void:
	interact_zone.interact = _on_interact
	tag_ui.visible = false
	update_tag_text()

func update_tag_text() -> void:
	if not GameManager.has_met_npc(npc_id):
		tag_ui.set_npc_name("???")
	else:
		tag_ui.set_npc_name(real_name)

# Rename these slightly so they can be called externally cleanly
func show_tag() -> void:
	update_tag_text()
	tag_ui.visible = true
	if tag_ui.has_method("idle"):
		tag_ui.idle()

func hide_tag() -> void:
	tag_ui.visible = false
	if tag_ui.has_method("stop_idle"):
		tag_ui.stop_idle()

# --- Proximity Tag Controls ---
func _on_player_entered(area: Area2D) -> void:
	print("Zone entered by area: ", area.name, " | Owner: ", area.owner.name)
	
	# Let's make it accept ANY area entry for a second just to see if it displays:
	update_tag_text()
	tag_ui.visible = true
	tag_ui.idle()

func _on_player_exited(area: Area2D) -> void:
	print("Zone exited by area: ", area.name)
	tag_ui.visible = false
	tag_ui.stop_idle()

func _on_interact() -> void:
	if GameManager.is_dialogue_active:
		return
		
	GameManager.next_dialogue_resource = dialogue
	GameManager.next_dialogue_start = dialogue_start
	GameManager.next_background_path = bg_image
	GameManager.set_pause_music(true)
	
	var ui = get_tree().root.find_child("ConversationUI", true, false)
	if ui:
		if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_finished):
			DialogueManager.dialogue_ended.connect(_on_dialogue_finished)
			
		ui.start_ui()

func _on_dialogue_finished(_resource: DialogueResource) -> void:
	
	GameManager.mark_npc_as_met(npc_id)
	update_tag_text()
	
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_finished):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_finished)

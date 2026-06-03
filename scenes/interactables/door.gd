extends Node2D

@onready var interactable: Area2D = $Sprite2D/Interactable

## The actual .dialogue file containing your text (Assign in Inspector)
@export var dialogue_resource: DialogueResource 
## The title marker inside your dialogue file (e.g., "start")
@export var dialogue_start_title: String = "start"

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact() -> void:
	# Add a flag here after this specific section is done.
	# Allows for free roam.
	
	if GameManager.is_true("the_truth") or GameManager.is_true("the_liar"):
		
		if dialogue_resource:
			# Feed the parameters into your GameManager like the UI expects
			GameManager.next_dialogue_resource = dialogue_resource
			GameManager.next_dialogue_start = dialogue_start_title
			GameManager.next_background_path = ""
			GameManager.set_pause_music(false)

			# Open the UI window frame
			UIManager.set_open("Dialogue", true)
			
			var ui = get_tree().root.find_child("ConversationUI", true, false)
			if ui:
				ui.start_ui()
			else:
				print("Could not find ConversationUI in the scene tree!")
		else:
			print("You forgot to drag your .dialogue file into the Door's inspector slot!")
			
	else:
		interactable._on_interact_triggered()

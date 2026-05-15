extends Node

# These variables hold the "info" for the next scene

func _ready():
	# This connects to the plugin's "closed" signal
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(_resource):
	get_tree().paused = false

var next_dialogue_resource: DialogueResource
var next_dialogue_start: String = "start"
var next_background_path: String = ""

# Saves player position
var player_return_position: Vector2 = Vector2.ZERO

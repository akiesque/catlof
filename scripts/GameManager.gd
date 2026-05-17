extends Node

# These variables hold the "info" for the next scene

func _ready():
	# This connects to the plugin's "closed" signal
	# DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
func _on_dialogue_ended(_resource):
	get_tree().paused = false

var next_dialogue_resource: DialogueResource
var next_dialogue_start: String = "start"
var next_background_path: String = ""

# Saves player position
var player_return_position: Vector2 = Vector2.ZERO
var target_spawn_id: String = ""
var player_saved_pos: Vector2
var use_saved_position: bool = false

func save_player_state(pos: Vector2):
	player_saved_pos = pos
	use_saved_position = true

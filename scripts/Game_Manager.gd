extends Node

func _ready():
	pass
	
var next_dialogue_resource: DialogueResource
var next_dialogue_start: String = "start"
var next_background_path: String = ""
var is_dialogue_active: bool = false
var hourui_firsttime := true

# Saves player position
var player_return_position: Vector2 = Vector2.ZERO
var target_spawn_id: String = ""
var player_saved_pos : Vector2
var use_saved_position : bool = false

#Locking inputs for future stuff
var unlocked_book := true
var unlock_crafting := false
var unlock_cooking := false

#Items interacted for the first time
var flag = {
	"interacted_table": false,
	"show_time": false,
	
}

# Helper functions for dictionary flag
func is_true(n: String) -> bool:
	return flag.get(n, false)
	
func set_true(n: String):
	flag[n] = true
	
func set_false(n: String):
	flag[n] = false

func save_player_state(pos: Vector2):
	player_saved_pos = pos
	use_saved_position = true
	
#For hour effect in UI
#GameManager.gd (Autoload)
var hour: int = 0
var pending_hour_update: bool = false
var next_hour_value: int = 0

signal hour_changed(new_hour)
signal show_hour_ui
signal hide_hour_ui

func add_hour(amount: int = 1):
	next_hour_value = hour + amount
	pending_hour_update = true

func hour_ui():
	emit_signal("show_hour_ui")

func no_hour_ui():
	emit_signal("hide_hour_ui")

func apply_the_new_hour() -> void:
	if pending_hour_update:
		hour = next_hour_value
		emit_signal("hour_changed", hour)
		pending_hour_update = false

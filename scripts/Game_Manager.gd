extends Node

signal flag_changed

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
var use_saved_position := false

#Locking inputs for future stuff
var unlocked_book := true
var unlock_crafting := true
var sprint_unlock := true # change upon release

# Music pausing
var pause_music:= true

# Helper
func set_pause_music(value: bool) -> void:
	pause_music = value

#Met NPCs dict
var met_npcs:= {
	"heine": false,
	"bel": false,
	"vivi": false,
	"lyn": false,
	"frees": false,
	"quiyn": false,
	"ama": false
}

#Helpers to set to true + checker
func mark_npc_as_met(npc_id: String) -> void:
	if npc_id != "":
		met_npcs[npc_id] = true

func has_met_npc(npc_id: String) -> bool:
	return met_npcs.has(npc_id) and met_npcs[npc_id] == true

#Items interacted for the first time
var flag = {
	"interacted_table": false,
	"show_time": false,
	"about_tourists": false,
	"about_sirens": false,
	"about_elementals": false,
	"about_dragonborns": false,
	"slept_bed": false,
	"interacted_bed": false,
	"the_liar": false,
	"the_truth": false
	
}

# Helper functions for dictionary flag
func is_true(n: String) -> bool:
	return flag.get(n, false)
	
func set_true(n: String):
	flag[n] = true
	flag_changed.emit()
	
func set_false(n: String):
	flag[n] = false
	flag_changed.emit()

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

# UIManager.gd
extends Node

# Register all managed UIs here
var ui_states: Dictionary = {
	"BagUI": false,
	"CraftCookUI": false,
	"Transition": false,
	"HourUI": false, 
	"Dialogue" : false,
}

# UIs that don't block other UIs from opening
const NON_BLOCKING = ["HourUI", "Transition"]

func _ready() -> void:
	print("DialogueManager signals: ", DialogueManager.get_signal_list().map(func(s): return s["name"]))
	DialogueManager.dialogue_started.connect(func(_r): 
		print("Dialogue started!")
		set_open("Dialogue", true)
	)
	DialogueManager.dialogue_ended.connect(func(_r): 
		print("Dialogue ended!")
		set_open("Dialogue", false)
	)
# Helper in UIManager
func blocker() -> void:
	if not is_any_ui_open():
		get_tree().paused = false

func is_any_ui_open() -> bool:
	for key in ui_states:
		if key in NON_BLOCKING:
			continue
		if ui_states[key]:
			return true
	return false

func is_blocked() -> bool:
	# Block input if transition is playing
	if ui_states.get("Transition", false):
		return true
	if GameManager.hourui_firsttime and ui_states.get("HourUI", false):
		return true
	return false

func set_open(ui_name: String, open: bool) -> void:
	if ui_states.has(ui_name):
		ui_states[ui_name] = open
	else:
		push_warning("UIManager: unknown UI: " + ui_name)

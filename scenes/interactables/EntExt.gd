extends Area2D

enum TriggerType { PRESS_UP, PRESS_DOWN, AUTOMATIC }

@export var trigger_mode: TriggerType = TriggerType.PRESS_UP

@export_file("*.tscn") var destination_scene: String
@export var spawn_location_name: String = "FromOutside"
@export var transition_color: Color = "#ffffff"
@export var sfx_door: AudioStream 

var interact: Callable
var is_interactable: bool = true 

func _ready() -> void:
	interact = _on_interact_triggered
	Transition.play_fade_in(transition_color)
	body_entered.connect(_on_body_entered)

func _on_interact_triggered() -> void:
	if GameManager.is_dialogue_active:
		return
	execute_transition()

func _on_body_entered(body: Node2D) -> void:
	if trigger_mode == TriggerType.AUTOMATIC and body.is_in_group("Player"):
		if GameManager.is_dialogue_active:
			return
		execute_transition()

func execute_transition() -> void:
	GameManager.target_spawn_id = spawn_location_name
	GameManager.use_saved_position = false
	
	MusicManager.play_sfx(sfx_door)
	Transition.play_fade_out(transition_color) 
	await Transition.anim_player.animation_finished
	
	if destination_scene != "":
		get_tree().change_scene_to_file(destination_scene)
	else:
		print("Oops! No scene set on this door.")

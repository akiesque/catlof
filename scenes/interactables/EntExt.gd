extends Area2D

@export_file("*.tscn") var destination_scene: String
@export var spawn_location_name: String = "FromOutside"
@export var transition_color: Color = ""

var interact: Callable
var is_interactable: bool = true 

func _ready() -> void:
	interact = _on_interact_triggered
	Transition.play_fade_out(transition_color)

func _on_interact_triggered():
	# Set the destination
	GameManager.target_spawn_id = spawn_location_name
	GameManager.use_saved_position = false
	
	Transition.play_fade_in(transition_color) 
	await Transition.anim_player.animation_finished
	
	# 2. Change the scene
	if destination_scene != "":
		get_tree().change_scene_to_file(destination_scene)
	else:
		print("Oops! No scene set on this door.")

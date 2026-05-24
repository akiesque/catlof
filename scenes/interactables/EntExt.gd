extends Area2D

# Exits/Stairs = true. Mailboxes/NPCs = false.
@export var needs_up_input: bool = true 

@export_file("*.tscn") var destination_scene: String
@export var spawn_location_name: String = "FromOutside"
@export var transition_color: Color = "#ffffff"
@export var sfx_door: AudioStream 

var interact: Callable
var is_interactable: bool = true 

func _ready() -> void:
	interact = _on_interact_triggered
	Transition.play_fade_in(transition_color)

func _on_interact_triggered():
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		if player.dir != "up" and not Input.is_action_pressed("move_up"):
			return
	# Set the destination
	GameManager.target_spawn_id = spawn_location_name
	GameManager.use_saved_position = false
	
	MusicManager.play_sfx(sfx_door)
	Transition.play_fade_out(transition_color) 
	await Transition.anim_player.animation_finished
	
	# 2. Change the scene
	if destination_scene != "":
		get_tree().change_scene_to_file(destination_scene)
	else:
		print("Oops! No scene set on this door.")

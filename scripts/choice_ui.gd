extends Control

signal choice_selected(next_id: String)

@onready var main_a: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var entr: AnimationPlayer = $CanvasLayer/Control/Sprite2D/Entr
@onready var layer: CanvasLayer = $CanvasLayer
@onready var choice_box: VBoxContainer = $CanvasLayer/ChoiceBox/Options
@onready var sfx_player: AudioStreamPlayer = $CanvasLayer/SFX_Player
@onready var sprite: AnimatedSprite2D = $CanvasLayer/Control/Sprite2D/AnimatedSprite2D


var is_animating: bool = false
var sfx: AudioStream = null

#preload
const CHOICES_DING = preload("uid://bbsq8arbhelws")
const CHOICES_PICK = preload("uid://ddvk7eq5ruegs")

const CHOICE_BTN = preload("res://scenes/choice_button.tscn")

func _ready():
	print("choice_box node: ", choice_box)
	layer.visible = false

func display_choices(responses: Array):
	sfx_player.stream = CHOICES_DING
	sfx_player.play()
	is_animating = true 
	layer.visible = true
	choice_box.modulate.a = 0 
	
	for child in choice_box.get_children():
		child.free()
		
	print("children after clear: ", choice_box.get_children().size())
	print("responses count: ", responses.size())
		
	for i in range(responses.size()):
		var response = responses[i]
		var btn = CHOICE_BTN.instantiate() 
		btn.get_node("Label").text = response.text
		btn.get_node("Button").pressed.connect(_on_choice_pressed.bind(response.next_id))
		choice_box.add_child(btn)
		
		await get_tree().process_frame

	var buttons = choice_box.get_children()
	for i in buttons.size():
		var btn = buttons[i].get_node("Button")
		btn.focus_mode = Control.FOCUS_ALL
		btn.focus_neighbor_top = buttons[wrap(i - 1, 0, buttons.size())].get_node("Button").get_path()
		btn.focus_neighbor_bottom = buttons[wrap(i + 1, 0, buttons.size())].get_node("Button").get_path()
		btn.focus_neighbor_left = btn.get_path() 
		btn.focus_neighbor_right = btn.get_path()
		
	buttons[0].get_node("Button").grab_focus()
	
	choice_box.modulate.a = 1
	if main_a.has_animation("enter"):
		sprite.play("blink")
		main_a.play("enter")
		entr.play("enter")  
		await main_a.animation_finished 

	if entr.has_animation("loop"):
		entr.play("loop")
		
	is_animating = false
			
	
func _on_choice_pressed(next_id: String):
	is_animating = true  
	sfx_player.stream = CHOICES_PICK
	sfx_player.play()
	entr.stop(false)
	sprite.play("turn_away")
	for btn in choice_box.get_children():
		btn.get_node("Button").disabled = true
		var tween = btn.create_tween()
		tween.tween_property(btn, "modulate", Color(0.325, 0.407, 0.591, 0.6), 0.15)
	await get_tree().create_timer(0.3).timeout
	
	if main_a.has_animation("enter"):
		main_a.play_backwards("enter")
		await main_a.animation_finished
		is_animating = false
		
	layer.visible = false
	choice_selected.emit(next_id)

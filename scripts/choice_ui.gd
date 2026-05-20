extends Control

signal choice_selected(next_id: String)

@onready var main_a: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var entr: AnimationPlayer = $CanvasLayer/Control/Sprite2D/Entr
@onready var layer: CanvasLayer = $CanvasLayer
@onready var choice_box: VBoxContainer = $CanvasLayer/ChoiceBox/Options


const CHOICE_BTN = preload("res://scenes/choice_button.tscn")

func _ready():
	print("choice_box node: ", choice_box)
	layer.visible = false

func display_choices(responses: Array):
	print("--- ChoiceUI Script: display_choices CALLED ---")
	layer.visible = true
	
	for child in choice_box.get_children():
		child.free()
		
	print("children after clear: ", choice_box.get_children().size())
	print("responses count: ", responses.size())
		
	for i in range(responses.size()):
		var response = responses[i]
		var btn = CHOICE_BTN.instantiate() 
		btn.text = response.text
		btn.pressed.connect(_on_choice_pressed.bind(response.next_id))
		choice_box.add_child(btn)
		
		if i == 0:
			btn.grab_focus()
	
	if main_a.has_animation("enter"):
		main_a.play("enter")
		entr.play("enter")  
		await main_a.animation_finished 

	if entr.has_animation("loop"):
		entr.play("loop")
			

func _on_choice_pressed(next_id: String):
	entr.stop(false)
	for btn in choice_box.get_children():
		if btn is Button: btn.disabled = true
	if main_a.has_animation("enter"):
		main_a.play_backwards("enter")
		await main_a.animation_finished
	layer.visible = false
	choice_selected.emit(next_id)

extends Control

signal choice_selected(next_id: String)

@onready var choice_box: NinePatchRect = $CanvasLayer/Options/ChoiceBox
@onready var main_a: AnimationPlayer = $AnimationPlayer
@onready var layer: CanvasLayer = $CanvasLayer

func _ready():
	hide()
	layer.visible = false

func display_choices(responses: Array):
	# 1. Wake the UI
	self.show()
	layer.visible = true
	
	# 2. Clear old buttons
	for child in choice_box.get_children():
		child.queue_free()
		
	# 3. Build buttons
	for response in responses:
		var btn = Button.new()
		btn.text = response.text
		btn.custom_minimum_size = Vector2(200, 50) 
		# This connects the button to the function below
		btn.pressed.connect(_on_choice_pressed.bind(response.next_id))
		choice_box.add_child(btn) 
	
	# 4. Play Animation
	if main_a.has_animation("enter"):
		main_a.play("enter")

## THIS IS THE MISSING FUNCTION THAT WAS CAUSING THE ERROR
func _on_choice_pressed(next_id: String):
	# Disable buttons to prevent double-clicking
	for btn in choice_box.get_children():
		if btn is Button:
			btn.disabled = true
			
	# Play exit animation
	if main_a.has_animation("enter"):
		main_a.s("enter")
		await main_a.animation_finished
	
	# Hide everything
	layer.visible = false
	hide()
	
	# Emit the signal to let the dialogue script know which choice was picked
	choice_selected.emit(next_id)

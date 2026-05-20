extends NinePatchRect

@onready var label: Label = $Label
@onready var btn: Button = $Button

func _ready():
	btn.focus_entered.connect(func(): label.add_theme_color_override("font_color", Color("313039")))
	btn.focus_exited.connect(func(): label.add_theme_color_override("font_color", Color.WHITE))
	btn.focus_entered.connect(_on_focus)
	btn.focus_exited.connect(_on_unfocus)
	
func _input(event):
	if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev"):
		get_viewport().set_input_as_handled() 
		

func _on_focus():
	label.add_theme_color_override("font_color", Color("313039"))
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + 25, 0.1)

func _on_unfocus():
	label.add_theme_color_override("font_color", Color.WHITE)
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x - 25, 0.1)

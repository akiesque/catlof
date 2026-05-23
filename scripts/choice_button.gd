extends Button

func _ready():
	focus_entered.connect(_on_focus)
	focus_exited.connect(_on_unfocus)

func _on_focus():
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + 25, 0.1)

func _on_unfocus():
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x - 25, 0.1)

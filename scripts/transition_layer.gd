extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer

const TRANSITION = preload("uid://dt77saequ7x3o")

@export var transition_color: Color = Color.BLACK:
	set(value):
		transition_color = value
		if color_rect:
			var tween = create_tween()
			tween.tween_property(color_rect.material, "shader_parameter/color", value, 0.7)

func play_fade_out(custom_color: Color = Color.BLACK):
	self.transition_color = custom_color
	anim_player.play("fade_out")

func play_fade_in(custom_color: Color = Color.BLACK):
	self.transition_color = custom_color
	anim_player.play("fade_in")

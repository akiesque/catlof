@tool
extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var transition_color: Color = Color.BLACK:
	set(value):
		transition_color = value
		if color_rect:
			color_rect.material.set_shader_parameter("color", value)

# Argument for color

func play_fade_out(custom_color: Color = Color.BLACK):
	self.transition_color = custom_color
	anim_player.play("fade_out")

func play_fade_in(custom_color: Color = Color.BLACK):
	self.transition_color = custom_color
	anim_player.play("fade_in")

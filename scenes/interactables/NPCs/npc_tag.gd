extends Control

@onready var label: Label = $VBoxContainer/Panel/CharacterName
@onready var anim_play: AnimationPlayer = $AnimationPlayer

func set_npc_name(new_name: String) -> void:
	if label:
		label.text = new_name

func idle():
	anim_play.play("bouncey")	

func stop_idle():
	anim_play.stop()
	

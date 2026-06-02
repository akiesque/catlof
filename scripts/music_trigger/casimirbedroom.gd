extends Node2D

@onready var bgm =  preload("res://assets/ui/music/藍とメロウ.mp3")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	MusicManager.play_bgm(bgm)

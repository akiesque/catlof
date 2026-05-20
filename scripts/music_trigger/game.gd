extends Node2D

@onready var bgm =  preload("uid://b6su73o7e5lwv")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	MusicManager.play_bgm(bgm)

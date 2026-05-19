extends CanvasLayer

@onready var hour_label: Label = $HourScreen/HourLabel
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sfx: AudioStreamPlayer = $SFXPlayer

const HOUR_UPDATE = preload("uid://dwi7r7cuw3x65")

func _ready() -> void:
	# 1. Connect to GameManager signals
	GameManager.hour_changed.connect(_on_hour_changed)
	GameManager.show_hour_ui.connect(_on_show_hour_ui)
	GameManager.hide_hour_ui.connect(_on_hide_hour_ui)
	
	visible = false 

func _on_hour_changed(new_hour: int) -> void:
	# Update the label text dynamically when the hour changes
	hour_label.text = str(new_hour)
	sfx.stream = HOUR_UPDATE
	sfx.play()
	

func _on_show_hour_ui() -> void:
	if GameManager.hourui_firsttime:
		visible = true
		anim.play("hourui_enter")
		await anim.animation_finished 
		GameManager.apply_the_new_hour()
		anim.play("floating")
		GameManager.hourui_firsttime = false
	else:
		await get_tree().create_timer(0.4).timeout
		GameManager.apply_the_new_hour()
		anim.play("floating")

func _on_hide_hour_ui() -> void:
	visible = false

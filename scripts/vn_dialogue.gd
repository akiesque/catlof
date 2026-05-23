extends Control

@onready var background_rect: TextureRect = $CanvasLayer/TextureRect
@onready var character_name: Label = $CanvasLayer/MarginContainer/DialogueBox/VBoxContainer/CharacterName
@onready var char_dialogue: RichTextLabel = $CanvasLayer/MarginContainer/DialogueBox/VBoxContainer/CharDialogue
@onready var layer: CanvasLayer = $CanvasLayer
@onready var anim: AnimationPlayer = $Animation
@onready var ctc: TextureRect = $CanvasLayer/MarginContainer/DialogueBox/Control/AdvanceCtc
@onready var ctc_anim: AnimationPlayer = $CanvasLayer/MarginContainer/DialogueBox/Control/AnimationPlayer

# Separated CTC SFX and Voice
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var ui_player: AudioStreamPlayer = $CtcPlayer

#Choices
@onready var choice_ui: Control = $CanvasLayer/ChoiceUI
var choice_visible :=  false

const SFX_CTC = preload("res://assets/ui/sfx/ctc_sfx.mp3")

# Preloads all beep sounds here
const VOICES = {
	"Casimir": preload("res://assets/Sounds/bleep007.wav"),
	"Default": preload("res://assets/Sounds/bleep005.wav") 
}

var current_line: DialogueLine
var is_typing: bool = false
var typing_tween: Tween
var current_voice_sfx: AudioStream = null
var last_played_character_index: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer.visible = false
	self.hide()
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	choice_ui.choice_selected.connect(_on_choice_resolved)
	
func _process(_delta):
	if not is_typing: return
	
	var current_idx = char_dialogue.visible_characters
	
	if current_idx > last_played_character_index:
		var parsed_text = char_dialogue.get_parsed_text()
		
		for i in range(last_played_character_index, current_idx):
			if i < parsed_text.length():
				var current_char = parsed_text[i]
				
				if current_char != " " and current_char != "." and current_char != "," and current_char != "?" and current_char != "!":
					if current_voice_sfx:
						if not voice_player.playing:
							voice_player.pitch_scale = randf_range(0.95, 1.05)
							voice_player.stream = current_voice_sfx
							voice_player.play()
						break 
						
		last_played_character_index = current_idx

func start_ui():
	GameManager.is_dialogue_active = true
	char_dialogue.text = ""
	character_name.text = ""
	char_dialogue.visible_characters = 0
	_hide_ctc() 
	
	if GameManager.next_background_path != "":
		background_rect.texture = load(GameManager.next_background_path)

	self.show()
	layer.visible = true
	
	if get_parent() and get_parent().has_method("set_process_input"):
		get_parent().process_mode = Node.PROCESS_MODE_DISABLED

	anim.play("enter")
	await anim.animation_finished

	update_line(GameManager.next_dialogue_start)

func update_line(title: String):
	current_line = await DialogueManager.get_next_dialogue_line(GameManager.next_dialogue_resource, title)
	
	if current_line:
		_hide_ctc()
		character_name.text = current_line.character
		char_dialogue.text = current_line.text
		char_dialogue.visible_characters = 0
		
		match current_line.character:
			"Casimir":
				current_voice_sfx = VOICES["Casimir"]
				character_name.add_theme_color_override("font_color", Color("#4454b1"))
			"Vivianne":
				current_voice_sfx = VOICES["Default"]
				character_name.add_theme_color_override("font_color", Color.MEDIUM_PURPLE)
			_:
				current_voice_sfx = VOICES["Default"]
				character_name.add_theme_color_override("font_color", Color.BLACK)
		
		last_played_character_index = 0
		is_typing = true
		
		if typing_tween:
			typing_tween.kill()
		typing_tween = create_tween()
		typing_tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
		
		var total_chars = char_dialogue.get_total_character_count()
		typing_tween.tween_property(char_dialogue, "visible_characters", total_chars, total_chars * 0.04)
		typing_tween.tween_callback(_on_typing_finished)
	else:
		_on_dialogue_ended(null)
		
func _on_typing_finished():
	if typing_tween == null: return
	print("tween finished!")
	is_typing = false
	if current_line and current_line.responses.size() > 0:
		_show_choices()
	else:
		_show_ctc()

func _show_choices():
	choice_visible = true
	_hide_ctc()
	if choice_ui:
		await get_tree().process_frame
		choice_ui.display_choices(current_line.responses)

func _on_choice_resolved(next_id: String):
	choice_visible = false
	current_line = null 
	update_line(next_id)

func _show_ctc():
	ctc.show()
	if ctc_anim and ctc_anim.has_animation("twirly"):
		ctc_anim.play("twirly")

func _hide_ctc():
	if ctc_anim:
		ctc_anim.stop()
	ctc.hide()

func _input(event):
	if not layer.visible: return
	if choice_visible: return
	if choice_ui.is_animating: return
	
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if is_typing:
			if typing_tween: 
				typing_tween.kill()
				typing_tween = null  
			char_dialogue.visible_characters = -1
			is_typing = false
			if current_line and current_line.responses.size() > 0:
				_show_choices()
			else:
				_show_ctc()
		elif current_line:
			ui_player.pitch_scale = 1.0
			ui_player.stream = SFX_CTC
			ui_player.play()
			update_line(current_line.next_id)


func _on_dialogue_ended(_resource):
	anim.play("exit")
	await anim.animation_finished
	GameManager.is_dialogue_active = false
	layer.visible = false
	self.hide()
	
	get_tree().paused = false
	#Call hour UI
	if GameManager.is_true("show_time"):
		GameManager.hour_ui()
		GameManager.set_false("show_time")

	if get_parent():
		get_parent().process_mode = Node.PROCESS_MODE_INHERIT

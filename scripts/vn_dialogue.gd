extends Control

@onready var background_rect: TextureRect = $CanvasLayer/TextureRect
@onready var character_name: Label = $CanvasLayer/MarginContainer/DialogueBox/VBoxContainer/CharacterName
@onready var char_dialogue: RichTextLabel = $CanvasLayer/MarginContainer/DialogueBox/VBoxContainer/CharDialogue
@onready var layer: CanvasLayer = $CanvasLayer
@onready var voicebox: ACVoiceBox = $ACVoicebox
@onready var anim: AnimationPlayer = $Animation


var current_line: DialogueLine
var is_typing: bool = false
var typing_tween: Tween

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer.visible = false
	self.hide()
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func start_ui():
	char_dialogue.text = ""
	character_name.text = ""
	char_dialogue.visible_characters = 0
	voicebox.stop()
	
	if GameManager.next_background_path != "":
		background_rect.texture = load(GameManager.next_background_path)

	# 3. Show UI structure
	self.show()
	layer.visible = true
	get_tree().paused = true
	anim.play("enter")
	await anim.animation_finished

	update_line(GameManager.next_dialogue_start)

func update_line(title: String):
	current_line = await DialogueManager.get_next_dialogue_line(GameManager.next_dialogue_resource, title)
	
	if current_line:
		character_name.text = current_line.character
		char_dialogue.text = current_line.text
		char_dialogue.visible_characters = 0
		is_typing = true
		
		match current_line.character:
			"Casimir": voicebox.base_pitch = 2.8
			_: voicebox.base_pitch = 3.5
		
		if typing_tween: typing_tween.kill()
		typing_tween = create_tween()
		var duration = char_dialogue.get_total_character_count() * 0.04
		typing_tween.tween_property(char_dialogue, "visible_characters", char_dialogue.get_total_character_count(), duration)
		typing_tween.finished.connect(func(): is_typing = false)
		
		var raw_text = char_dialogue.get_parsed_text()
		var regex = RegEx.new()
		regex.compile("[^a-zA-Z0-9 ]")
		var clean = regex.sub(raw_text, "", true)
		
		var words = []
		for word in clean.split(" "):
			if word.length() > 0:
				words.append(word)
		
		var voice_string = " ".join(words)
		
		if voice_string.length() > 0:
			voicebox.play_string(voice_string)
	else:
		_on_dialogue_ended(null)

func _input(event):
	if not layer.visible: return
	
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if is_typing:
			if typing_tween: typing_tween.kill()
			voicebox.stop() 
			char_dialogue.visible_characters = -1
			is_typing = false
		elif current_line:
			update_line(current_line.next_id)

func _on_dialogue_ended(_resource):
	anim.play("exit")
	await anim.animation_finished
	layer.visible = false
	self.hide()
	get_tree().paused = false

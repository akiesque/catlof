extends Area2D

@onready var sfx_player: AudioStreamPlayer = $SFX_Player
@onready var notif_label: Label = $NotifLabel

# Save the original layout position so we can reset it after it floats up
@onready var original_y_pos: float = notif_label.position.y

func _ready() -> void:
	# Ensure the whole detector can process even if the rest of the world pauses
	process_mode = Node.PROCESS_MODE_ALWAYS
	if sfx_player:
		sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
		
	if notif_label:
		notif_label.hide()

func play_pickup_effects(item_name: String) -> void:
	# 1. Play the audio cue cleanly
	if sfx_player and sfx_player.stream:
		sfx_player.play()
		
	if notif_label:
		# --- FIXED: REMOVED THE SELF-KILLING TWEEN LINES ---
		
		# 2. Setup text and reset positions
		notif_label.position.y = original_y_pos
		notif_label.modulate.a = 1.0
		notif_label.text = item_name + " +1"
		
		# 3. REVEAL THE LABEL NOW!
		notif_label.show()
		
		# 4. Create the float and fade animation sequence safely
		var tween = create_tween().set_parallel(true)
		
		# Float upward over 1.2 seconds
		tween.tween_property(notif_label, "position:y", original_y_pos - 30, 1.2)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			
		# Fade out completely
		tween.tween_property(notif_label, "modulate:a", 0.0, 1.2)
		
		# 5. Hide the label again when the animation finishes
		tween.chain().tween_callback(notif_label.hide)

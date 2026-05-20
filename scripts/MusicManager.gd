extends Node

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8 

func _ready():
	# This ensures the manager keeps running
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	add_child(music_player)
	# This ensures the PLAYER specifically keeps playing
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = "BGM"
	
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.process_mode = Node.PROCESS_MODE_ALWAYS # SFX should play in menus too!
		add_child(p)
		p.bus = "SFX"
		sfx_pool.append(p)

func play_bgm(stream: AudioStream, fade_duration: float = 1.0):
	# If the same song is already playing, do nothing
	if music_player.stream == stream: 
		return
	
	var tween = create_tween()
	
	if music_player.playing:
		# FADE OUT existing music
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		# SWAP music and start playing at silence
		tween.tween_callback(func():
			music_player.stream = stream
			music_player.play()
		)
	else:
		# If nothing is playing, just swap and start silent
		music_player.stream = stream
		music_player.volume_db = -80.0
		music_player.play()

	# FADE IN new music
	tween.tween_property(music_player, "volume_db", 0.0, fade_duration)

func play_sfx(stream: AudioStream):
	for p in sfx_pool:
		if not p.playing:
			p.stream = stream
			p.play()
			return

func stop_bgm(fade_duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
	tween.tween_callback(music_player.stop)

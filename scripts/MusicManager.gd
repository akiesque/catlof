extends Node

# ──── World BGM ────
@onready var music_player = AudioStreamPlayer.new()

# ──── Dialogue BGM crossfade pair ────
@onready var d_player_a = AudioStreamPlayer.new()
@onready var d_player_b = AudioStreamPlayer.new()
var d_active: AudioStreamPlayer = null   # which dialogue player is currently audible
var d_standby: AudioStreamPlayer = null

# ──── SFX pool ────
@onready var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8

# ──── World music save state ────
var saved_world_stream: AudioStream = null
var saved_world_position: float = 0.0

# ──── Fading ────
const FADE_DURATION = 1.0
var fade_tween: Tween
var dialogue_fade_tween: Tween

# ──── Preloaded tracks for zero‑hitch dialogue swaps ────
var preloaded_tracks: Dictionary = {}

# ──── Per‑track volume offsets ────
const TRACK_VOLUMES = {
	"res://assets/ui/music/自転車と青空.mp3": -6.5,
	"res://assets/ui/music/みんなでお出かけ.mp3": -8.5,
	"res://assets/ui/music/Dark_blue_night.mp3": -6.5,
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	# ── World music player ──
	add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = "BGM"

	# ── Dialogue crossfade players ──
	add_child(d_player_a)
	add_child(d_player_b)
	d_player_a.process_mode = Node.PROCESS_MODE_ALWAYS
	d_player_b.process_mode = Node.PROCESS_MODE_ALWAYS
	d_player_a.bus = "BGM"
	d_player_b.bus = "BGM"

	# Init standby state
	d_active = d_player_a
	d_standby = d_player_b

	# ── SFX pool ──
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		p.bus = "SFX"
		sfx_pool.append(p)

# ───────────────────────────────────────
# Utility
# ───────────────────────────────────────
func _get_target_volume(stream: AudioStream) -> float:
	if stream and not stream.resource_path.is_empty() and TRACK_VOLUMES.has(stream.resource_path):
		return TRACK_VOLUMES[stream.resource_path]
	return 0.0

func _safe_kill(tween_ref):
	if tween_ref and is_instance_valid(tween_ref):
		tween_ref.kill()

func _preload_track(path: String) -> void:
	if not preloaded_tracks.has(path):
		preloaded_tracks[path] = load(path)

# ───────────────────────────────────────
# World BGM
# ───────────────────────────────────────
func play_bgm(stream: AudioStream, custom_volume_db: float = 0.0):
	if music_player.stream == stream and music_player.playing:
		return

	_safe_kill(fade_tween)
	fade_tween = null

	# Use custom volume if provided, else fall back to dictionary
	var target_vol = custom_volume_db
	if target_vol == 0.0:   # 0 means "not overridden" in this case; you can use a sentinel like -999
		target_vol = _get_target_volume(stream)

	music_player.stop()
	music_player.stream = stream
	music_player.volume_db = -80.0
	music_player.play()
	music_player.seek(0.0)

	fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_db", target_vol, FADE_DURATION)
	fade_tween.tween_callback(func(): fade_tween = null)

func pause_world_music():
	if music_player.playing:
		saved_world_stream = music_player.stream
		saved_world_position = music_player.get_playback_position()

		_safe_kill(fade_tween)
		fade_tween = null

		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", -80.0, FADE_DURATION)
		fade_tween.tween_callback(func():
			music_player.stop()
			fade_tween = null
		)
		print("[MusicManager] World music fading out at position: ", saved_world_position)
	else:
		saved_world_stream = null
		saved_world_position = 0.0

func resume_world_music():
	if saved_world_stream != null:
		_safe_kill(fade_tween)
		fade_tween = null

		var target_vol = _get_target_volume(saved_world_stream)

		music_player.stop()
		music_player.stream = saved_world_stream
		music_player.volume_db = -80.0
		music_player.bus = "BGM"
		music_player.play()
		music_player.seek(saved_world_position)   # correct order: play → seek

		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", target_vol, FADE_DURATION)
		fade_tween.tween_callback(func(): fade_tween = null)

		print("[MusicManager] World music resumed at position: ", saved_world_position)

		saved_world_stream = null
		saved_world_position = 0.0
	else:
		print("[MusicManager] Nothing to resume.")

# ───────────────────────────────────────
# Dialogue BGM (crossfaded)
# ───────────────────────────────────────
func change_bgm_by_path(path: String):
	# Preload to avoid hitches
	_preload_track(path)
	var new_stream = preloaded_tracks[path]
	if not new_stream is AudioStream:
		push_error("[MusicManager] Invalid audio stream: " + path)
		return

	# If the exact same track is already playing on the active player, ignore.
	if d_active.stream == new_stream and d_active.playing:
		return

	_safe_kill(dialogue_fade_tween)
	dialogue_fade_tween = null

	var target_vol = _get_target_volume(new_stream)

	# ── Setup the silent (standby) player ──
	d_standby.stop()
	d_standby.stream = new_stream
	d_standby.volume_db = -80.0
	d_standby.play()
	d_standby.seek(0.0)

	# ── Crossfade: active fades out, standby fades in ──
	dialogue_fade_tween = create_tween()
	dialogue_fade_tween.set_parallel(true)

	# Fade out current active player (if it's actually playing)
	if d_active.playing:
		dialogue_fade_tween.tween_property(d_active, "volume_db", -80.0, FADE_DURATION)
		dialogue_fade_tween.tween_callback(func():
			d_active.stop()
		)

	# Fade in the new player
	dialogue_fade_tween.tween_property(d_standby, "volume_db", target_vol, FADE_DURATION)

	# After everything, swap roles
	dialogue_fade_tween.set_parallel(false)  # chain a final callback
	dialogue_fade_tween.tween_callback(func():
		# Swap active / standby
		var temp = d_active
		d_active = d_standby
		d_standby = temp
		dialogue_fade_tween = null
	)

	print("[MusicManager] Dialogue BGM crossfaded to: ", path)

## Call this when dialogue ends to silence the dialogue music.
func stop_dialogue_music():
	if d_active.playing:
		_safe_kill(dialogue_fade_tween)
		dialogue_fade_tween = null

		dialogue_fade_tween = create_tween()
		dialogue_fade_tween.tween_property(d_active, "volume_db", -80.0, FADE_DURATION)
		dialogue_fade_tween.tween_callback(func():
			d_active.stop()
			dialogue_fade_tween = null
		)

# ───────────────────────────────────────
# SFX
# ───────────────────────────────────────
func play_sfx(stream: AudioStream):
	for p in sfx_pool:
		if not p.playing:
			p.stream = stream
			p.play()
			return

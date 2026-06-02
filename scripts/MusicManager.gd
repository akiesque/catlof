extends Node

@onready var music_player = AudioStreamPlayer.new()
@onready var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE = 8 

var saved_world_stream: AudioStream = null
var saved_world_position: float = 0.0

const FADE_DURATION = 1.0
var fade_tween: Tween

const TRACK_VOLUMES = {
	"res://assets/ui/music/自転車と青空.mp3": -6.5,
	"res://assets/ui/music/みんなでお出かけ.mp3": -8.5,
	"res://assets/ui/music/Dark_blue_night.mp3": -6.5,
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	add_child(music_player)
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = "BGM"
	
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		p.bus = "SFX"
		sfx_pool.append(p)

func _get_target_volume(stream: AudioStream) -> float:
	if stream and TRACK_VOLUMES.has(stream.resource_path):
		return TRACK_VOLUMES[stream.resource_path]
	return 0.0

## Standard world music playback
func play_bgm(stream: AudioStream):
	if music_player.stream == stream and music_player.playing: 
		return
		
	if fade_tween: fade_tween.kill()
	var target_vol = _get_target_volume(stream)
	
	music_player.stop()
	music_player.stream = stream
	music_player.volume_db = -80.0
	music_player.play()
	
	fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_db", target_vol, FADE_DURATION)

## MANUALLY CALL THIS: Smoothly fades out and saves the world music state
func pause_world_music():
	if music_player.playing:
		saved_world_stream = music_player.stream
		saved_world_position = music_player.get_playback_position()
		
		if fade_tween: fade_tween.kill()
		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", -80.0, FADE_DURATION)
		fade_tween.tween_callback(music_player.stop)
		print("[MusicManager] World music fading out at position: ", saved_world_position)
	else:
		saved_world_stream = null
		saved_world_position = 0.0

## MANUALLY CALL THIS: Smoothly fades the world music back in from exactly where it was
func resume_world_music():
	if saved_world_stream != null:
		if fade_tween: fade_tween.kill()
		var target_vol = _get_target_volume(saved_world_stream)
		
		music_player.stop()
		music_player.stream = saved_world_stream
		music_player.volume_db = -80.0
		music_player.bus = "BGM"
		music_player.play(saved_world_position)
		
		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", target_vol, FADE_DURATION)
			
		print("[MusicManager] World music cleanly faded back in to position: ", saved_world_position)
		
		saved_world_stream = null
		saved_world_position = 0.0
	else:
		print("[MusicManager] Nothing to resume, stream was empty.")

## Helper called directly inside your .dialogue files (Spam-proof!)
func change_bgm_by_path(path: String):
	var new_track = load(path)
	if new_track is AudioStream:
		if music_player.stream == new_track and music_player.playing:
			return
			
		if fade_tween: fade_tween.kill()
		var target_vol = _get_target_volume(new_track)
		
		# We force a hard stop and immediate restart on the player component.
		# This stops old files from hanging in memory and makes sure the track changes instantly!
		music_player.stop()
		music_player.stream = new_track
		music_player.volume_db = -80.0
		music_player.play()
		
		fade_tween = create_tween()
		fade_tween.tween_property(music_player, "volume_db", target_vol, FADE_DURATION)
		
		print("[MusicManager] Swapped temporary track instantly to: ", path)

func play_sfx(stream: AudioStream):
	for p in sfx_pool:
		if not p.playing:
			p.stream = stream
			p.play()
			return

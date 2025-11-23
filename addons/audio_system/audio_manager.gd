extends Node

class_name AudioManager

signal audio_started(audio_type: String, audio_name: String)
signal audio_finished(audio_type: String, audio_name: String)
signal tts_started(character_id: String, text: String)
signal tts_finished(character_id: String)

@export var bgm_volume: float = 0.7
@export var sfx_volume: float = 0.8
@export var voice_volume: float = 0.9
@export var master_volume: float = 1.0

var bgm_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var voice_player: AudioStreamPlayer
var tts_player: AudioStreamPlayer

var current_bgm: String = ""
var loaded_audio: Dictionary = {}
var voice_cache: Dictionary = {}
var tts_enabled: bool = true
var current_language: String = "ko"

# TTS 설정 (각 캐릭터별 음성 설정)
var character_voices: Dictionary = {
	"yuki": {
		"pitch": 1.2,
		"speed": 1.0,
		"voice_type": "female_young"
	},
	"player": {
		"pitch": 0.9,
		"speed": 1.0,
		"voice_type": "male_young"
	},
	"narrator": {
		"pitch": 1.0,
		"speed": 0.9,
		"voice_type": "neutral"
	}
}

func _ready() -> void:
	_setup_audio_players()
	_setup_audio_buses()

func _setup_audio_players() -> void:
	# BGM 플레이어
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	bgm_player.bus = "BGM"
	add_child(bgm_player)
	
	# SFX 플레이어들 (동시 재생용)
	for i in range(8):  # 최대 8개 효과음 동시 재생
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer" + str(i)
		sfx_player.bus = "SFX"
		sfx_players.append(sfx_player)
		add_child(sfx_player)
	
	# 음성 플레이어
	voice_player = AudioStreamPlayer.new()
	voice_player.name = "VoicePlayer"
	voice_player.bus = "Voice"
	add_child(voice_player)
	
	# TTS 플레이어
	tts_player = AudioStreamPlayer.new()
	tts_player.name = "TTSPlayer"
	tts_player.bus = "TTS"
	add_child(tts_player)

func _setup_audio_buses() -> void:
	# 오디오 버스 생성 및 설정
	var master_bus = AudioServer.get_bus_index("Master")
	
	# BGM 버스
	if AudioServer.get_bus_index("BGM") == -1:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "BGM")
		AudioServer.set_bus_parent(1, master_bus)
	
	# SFX 버스
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "SFX")
		AudioServer.set_bus_parent(2, master_bus)
	
	# Voice 버스
	if AudioServer.get_bus_index("Voice") == -1:
		AudioServer.add_bus(3)
		AudioServer.set_bus_name(3, "Voice")
		AudioServer.set_bus_parent(3, master_bus)
	
	# TTS 버스
	if AudioServer.get_bus_index("TTS") == -1:
		AudioServer.add_bus(4)
		AudioServer.set_bus_name(4, "TTS")
		AudioServer.set_bus_parent(4, master_bus)

# BGM 제어
func play_bgm(audio_path: String, fade_in: bool = true, fade_duration: float = 1.0) -> void:
	var audio_stream = _load_audio(audio_path)
	if not audio_stream:
		push_error("Failed to load BGM: " + audio_path)
		return
	
	current_bgm = audio_path
	
	if fade_in and bgm_player.playing:
		await fade_out_bgm(fade_duration)
	
	bgm_player.stream = audio_stream
	bgm_player.volume_db = linear_to_db(bgm_volume * master_volume)
	
	if fade_in:
		bgm_player.volume_db = linear_to_db(0.0)
		bgm_player.play()
		await fade_in_bgm(fade_duration)
	else:
		bgm_player.play()
	
	emit_signal("audio_started", "bgm", audio_path)

func stop_bgm(fade_out: bool = true, fade_duration: float = 1.0) -> void:
	if not bgm_player.playing:
		return
	
	if fade_out:
		await fade_out_bgm(fade_duration)
	else:
		bgm_player.stop()
	
	emit_signal("audio_finished", "bgm", current_bgm)
	current_bgm = ""

func fade_in_bgm(duration: float) -> void:
	var tween = create_tween()
	tween.tween_method(_set_bgm_volume, 0.0, bgm_volume * master_volume, duration)
	await tween.finished

func fade_out_bgm(duration: float) -> void:
	var tween = create_tween()
	tween.tween_method(_set_bgm_volume, bgm_volume * master_volume, 0.0, duration)
	await tween.finished
	bgm_player.stop()

func _set_bgm_volume(volume: float) -> void:
	bgm_player.volume_db = linear_to_db(volume)

# 효과음 제어
func play_sfx(audio_path: String, pitch: float = 1.0, volume_modifier: float = 1.0) -> void:
	var audio_stream = _load_audio(audio_path)
	if not audio_stream:
		push_error("Failed to load SFX: " + audio_path)
		return
	
	var available_player = _get_available_sfx_player()
	if not available_player:
		push_warning("No available SFX player, stopping oldest")
		available_player = sfx_players[0]
		available_player.stop()
	
	available_player.stream = audio_stream
	available_player.volume_db = linear_to_db(sfx_volume * volume_modifier * master_volume)
	available_player.pitch_scale = pitch
	available_player.play()
	
	emit_signal("audio_started", "sfx", audio_path)
	
	# 재생 완료 시그널 연결
	if not available_player.finished.is_connected(_on_sfx_finished):
		available_player.finished.connect(_on_sfx_finished.bind(audio_path))

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return null

func _on_sfx_finished(audio_path: String) -> void:
	emit_signal("audio_finished", "sfx", audio_path)

# 음성 제어
func play_voice(audio_path: String, character_id: String = "") -> void:
	var audio_stream = _load_audio(audio_path)
	if not audio_stream:
		push_error("Failed to load voice: " + audio_path)
		return
	
	# 기존 음성 중단
	if voice_player.playing:
		voice_player.stop()
	
	voice_player.stream = audio_stream
	voice_player.volume_db = linear_to_db(voice_volume * master_volume)
	
	# 캐릭터별 음성 설정 적용
	if character_voices.has(character_id):
		var voice_settings = character_voices[character_id]
		voice_player.pitch_scale = voice_settings.get("pitch", 1.0)
	
	voice_player.play()
	emit_signal("audio_started", "voice", audio_path)
	
	# 재생 완료 시그널
	voice_player.finished.connect(_on_voice_finished.bind(audio_path), CONNECT_ONE_SHOT)

func _on_voice_finished(audio_path: String) -> void:
	emit_signal("audio_finished", "voice", audio_path)

func stop_voice() -> void:
	if voice_player.playing:
		voice_player.stop()

# TTS 제어
func speak_text(text: String, character_id: String = "narrator", interrupt: bool = true) -> void:
	if not tts_enabled:
		return
	
	if interrupt and tts_player.playing:
		tts_player.stop()
	
	# 실제 TTS는 외부 시스템 연동이 필요하므로 여기서는 기본 구조만 제공
	emit_signal("tts_started", character_id, text)
	
	# TTS 생성 로직 (플래그홀더)
	var tts_audio = _generate_tts_audio(text, character_id)
	if tts_audio:
		tts_player.stream = tts_audio
		tts_player.volume_db = linear_to_db(voice_volume * master_volume)
		
		# 캐릭터 음성 설정 적용
		if character_voices.has(character_id):
			var voice_settings = character_voices[character_id]
			tts_player.pitch_scale = voice_settings.get("pitch", 1.0)
		
		tts_player.play()
		tts_player.finished.connect(_on_tts_finished.bind(character_id), CONNECT_ONE_SHOT)

func _generate_tts_audio(text: String, character_id: String) -> AudioStream:
	# 실제 구현에서는 외부 TTS 서비스(Google TTS, Azure TTS 등) 연동
	# 여기서는 기본 구조만 제공
	print("TTS: [%s] %s" % [character_id, text])
	return null

func _on_tts_finished(character_id: String) -> void:
	emit_signal("tts_finished", character_id)

# 다국어 음성 지원
func set_language(language_code: String) -> void:
	current_language = language_code
	# 언어별 음성 캐시 정리
	voice_cache.clear()

func get_localized_audio_path(base_path: String, language: String = "") -> String:
	if language.is_empty():
		language = current_language
	
	# 예: "res://audio/voice/greeting.ogg" -> "res://audio/voice/ko/greeting.ogg"
	var path_parts = base_path.split("/")
	var filename = path_parts[-1]
	var dir_path = "/".join(path_parts.slice(0, -1))
	
	return dir_path + "/" + language + "/" + filename

# 오디오 로딩 및 캐싱
func _load_audio(audio_path: String) -> AudioStream:
	if loaded_audio.has(audio_path):
		return loaded_audio[audio_path]
	
	var audio_stream = load(audio_path)
	if audio_stream:
		loaded_audio[audio_path] = audio_stream
	
	return audio_stream

func preload_audio(audio_paths: Array[String]) -> void:
	for path in audio_paths:
		_load_audio(path)

func clear_audio_cache() -> void:
	loaded_audio.clear()
	voice_cache.clear()

# 볼륨 제어
func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	_update_all_volumes()

func set_bgm_volume(volume: float) -> void:
	bgm_volume = clamp(volume, 0.0, 1.0)
	if bgm_player:
		bgm_player.volume_db = linear_to_db(bgm_volume * master_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = linear_to_db(sfx_volume * master_volume)

func set_voice_volume(volume: float) -> void:
	voice_volume = clamp(volume, 0.0, 1.0)
	if voice_player:
		voice_player.volume_db = linear_to_db(voice_volume * master_volume)
	if tts_player:
		tts_player.volume_db = linear_to_db(voice_volume * master_volume)

func _update_all_volumes() -> void:
	set_bgm_volume(bgm_volume)
	set_sfx_volume(sfx_volume)
	set_voice_volume(voice_volume)

# TTS 설정
func set_tts_enabled(enabled: bool) -> void:
	tts_enabled = enabled

func add_character_voice(character_id: String, voice_settings: Dictionary) -> void:
	character_voices[character_id] = voice_settings

# 오디오 상태
func is_bgm_playing() -> bool:
	return bgm_player.playing if bgm_player else false

func is_voice_playing() -> bool:
	return voice_player.playing if voice_player else false

func is_tts_playing() -> bool:
	return tts_player.playing if tts_player else false

func get_current_bgm() -> String:
	return current_bgm

# 저장/로드
func get_audio_state() -> Dictionary:
	return {
		"master_volume": master_volume,
		"bgm_volume": bgm_volume,
		"sfx_volume": sfx_volume,
		"voice_volume": voice_volume,
		"current_bgm": current_bgm,
		"tts_enabled": tts_enabled,
		"current_language": current_language
	}

func load_audio_state(state: Dictionary) -> void:
	master_volume = state.get("master_volume", 1.0)
	bgm_volume = state.get("bgm_volume", 0.7)
	sfx_volume = state.get("sfx_volume", 0.8)
	voice_volume = state.get("voice_volume", 0.9)
	tts_enabled = state.get("tts_enabled", true)
	current_language = state.get("current_language", "ko")
	
	_update_all_volumes()
	
	var saved_bgm = state.get("current_bgm", "")
	if not saved_bgm.is_empty():
		play_bgm(saved_bgm, false)
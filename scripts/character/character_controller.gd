extends Node2D

# 캐릭터 컨트롤러
# 캐릭터의 표정, 포즈, 애니메이션, 음성을 관리

signal animation_completed
signal voice_completed

# 캐릭터 기본 정보
var character_id: String
var character_name: String
var default_position: Vector2

# 현재 상태
var current_emotion: String = "normal"
var current_pose: String = "default"
var is_speaking: bool = false

# 노드 참조
@onready var sprite = $Sprite
@onready var animation_player = $AnimationPlayer
@onready var voice_player = $VoicePlayer
@onready var tween_manager = $TweenManager

# 리소스 캐시
var emotions: Dictionary = {}  # 표정별 텍스처
var poses: Dictionary = {}     # 포즈별 텍스처
var voice_clips: Dictionary = {} # 음성 클립

# 초기화
func _init(id: String, name: String, pos: Vector2 = Vector2(0, 0)):
    character_id = id
    character_name = name
    default_position = pos

func _ready():
    position = default_position
    _setup_animation_player()
    _connect_signals()

# 시그널 연결
func _connect_signals():
    animation_player.animation_finished.connect(_on_animation_finished)
    if voice_player:
        voice_player.finished.connect(_on_voice_finished)

# 애니메이션 플레이어 설정
func _setup_animation_player():
    # 기본 애니메이션 생성
    var appear_anim = Animation.new()
    var disappear_anim = Animation.new()
    var bounce_anim = Animation.new()
    
    # 등장 애니메이션
    var appear_track = appear_anim.add_track(Animation.TYPE_VALUE)
    appear_anim.track_set_path(appear_track, ".:modulate:a")
    appear_anim.track_insert_key(appear_track, 0.0, 0.0)
    appear_anim.track_insert_key(appear_track, 0.5, 1.0)
    
    # 퇴장 애니메이션
    var disappear_track = disappear_anim.add_track(Animation.TYPE_VALUE)
    disappear_anim.track_set_path(disappear_track, ".:modulate:a")
    disappear_anim.track_insert_key(disappear_track, 0.0, 1.0)
    disappear_anim.track_insert_key(disappear_track, 0.5, 0.0)
    
    # 바운스 애니메이션
    var bounce_track = bounce_anim.add_track(Animation.TYPE_VALUE)
    bounce_anim.track_set_path(bounce_track, ".:scale")
    bounce_anim.track_insert_key(bounce_track, 0.0, Vector2(1, 1))
    bounce_anim.track_insert_key(bounce_track, 0.1, Vector2(1.1, 0.9))
    bounce_anim.track_insert_key(bounce_track, 0.2, Vector2(0.9, 1.1))
    bounce_anim.track_insert_key(bounce_track, 0.3, Vector2(1, 1))
    
    animation_player.add_animation("appear", appear_anim)
    animation_player.add_animation("disappear", disappear_anim)
    animation_player.add_animation("bounce", bounce_anim)

# 표정 리소스 로드
func load_emotion(emotion_name: String, texture_path: String):
    var texture = load(texture_path)
    if texture:
        emotions[emotion_name] = texture
    else:
        push_error("표정 텍스처를 로드할 수 없습니다: " + texture_path)

# 포즈 리소스 로드
func load_pose(pose_name: String, texture_path: String):
    var texture = load(texture_path)
    if texture:
        poses[pose_name] = texture
    else:
        push_error("포즈 텍스처를 로드할 수 없습니다: " + texture_path)

# 음성 클립 로드
func load_voice_clip(clip_name: String, audio_path: String):
    var audio = load(audio_path)
    if audio:
        voice_clips[clip_name] = audio
    else:
        push_error("음성 클립을 로드할 수 없습니다: " + audio_path)

# 표정 변경
func change_emotion(emotion: String, duration: float = 0.3):
    if not emotions.has(emotion):
        push_error("존재하지 않는 표정입니다: " + emotion)
        return
    
    current_emotion = emotion
    var new_texture = emotions[emotion]
    
    var tween = create_tween()
    tween.tween_property(sprite, "modulate:a", 0, duration/2)
    tween.tween_callback(func():
        sprite.texture = new_texture
    )
    tween.tween_property(sprite, "modulate:a", 1, duration/2)

# 포즈 변경
func change_pose(pose: String, duration: float = 0.5):
    if not poses.has(pose):
        push_error("존재하지 않는 포즈입니다: " + pose)
        return
    
    current_pose = pose
    var new_texture = poses[pose]
    
    var tween = create_tween()
    tween.tween_property(sprite, "modulate:a", 0, duration/2)
    tween.tween_callback(func():
        sprite.texture = new_texture
    )
    tween.tween_property(sprite, "modulate:a", 1, duration/2)

# 캐릭터 이동
func move_to(target_pos: Vector2, duration: float = 1.0, ease_type: int = Tween.EASE_IN_OUT):
    var tween = create_tween()
    tween.set_ease(ease_type)
    tween.tween_property(self, "position", target_pos, duration)

# 캐릭터 등장
func appear(duration: float = 0.5):
    animation_player.play("appear")
    await animation_player.animation_finished

# 캐릭터 퇴장
func disappear(duration: float = 0.5):
    animation_player.play("disappear")
    await animation_player.animation_finished

# 말하기 시작
func start_speaking(voice_clip: String = ""):
    is_speaking = true
    animation_player.play("bounce")
    
    if not voice_clip.is_empty() and voice_clips.has(voice_clip):
        voice_player.stream = voice_clips[voice_clip]
        voice_player.play()

# 말하기 종료
func stop_speaking():
    is_speaking = false
    animation_player.stop()
    if voice_player.playing:
        voice_player.stop()

# 애니메이션 완료 시그널
func _on_animation_finished(anim_name: String):
    emit_signal("animation_completed", anim_name)

# 음성 재생 완료 시그널
func _on_voice_finished():
    emit_signal("voice_completed")
    if is_speaking:
        stop_speaking()
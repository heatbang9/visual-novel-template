extends Node2D

# 배경 효과 컨트롤러
# 배경 이미지 전환, 날씨 효과, 시간 변화 등을 관리

signal transition_completed
signal effect_started
signal effect_completed

@onready var background_sprite = $Background
@onready var effect_layer = $EffectLayer
@onready var tween_manager = $TweenManager

# 날씨 효과 파티클 시스템
@onready var rain_particles = $EffectLayer/RainParticles
@onready var snow_particles = $EffectLayer/SnowParticles
@onready var fog_particles = $EffectLayer/FogParticles

# 시간 변화용 오버레이
@onready var time_overlay = $TimeOverlay

enum TimeOfDay { DAY, SUNSET, NIGHT, SUNRISE }
enum Weather { CLEAR, RAIN, SNOW, FOG }

var current_weather = Weather.CLEAR
var current_time = TimeOfDay.DAY

func _ready():
    _initialize_components()

func _initialize_components():
    # 파티클 시스템 초기 설정
    rain_particles.emitting = false
    snow_particles.emitting = false
    fog_particles.emitting = false
    
    # 시간 오버레이 초기화
    time_overlay.modulate.a = 0

# 배경 전환 함수
func change_background(new_background_path: String, transition_type: String = "fade", duration: float = 1.0):
    var new_texture = load(new_background_path)
    if not new_texture:
        push_error("배경 이미지를 로드할 수 없습니다: " + new_background_path)
        return

    match transition_type:
        "fade":
            _fade_transition(new_texture, duration)
        "crossfade":
            _crossfade_transition(new_texture, duration)
        "instant":
            _instant_transition(new_texture)
        _:
            push_error("지원하지 않는 전환 타입입니다: " + transition_type)

# 페이드 전환
func _fade_transition(new_texture: Texture2D, duration: float):
    var tween = create_tween()
    tween.tween_property(background_sprite, "modulate:a", 0, duration / 2)
    tween.tween_callback(func():
        background_sprite.texture = new_texture
    )
    tween.tween_property(background_sprite, "modulate:a", 1, duration / 2)
    tween.finished.connect(func(): emit_signal("transition_completed"))

# 크로스페이드 전환
func _crossfade_transition(new_texture: Texture2D, duration: float):
    var temp_sprite = Sprite2D.new()
    temp_sprite.texture = new_texture
    temp_sprite.modulate.a = 0
    add_child(temp_sprite)

    var tween = create_tween()
    tween.parallel().tween_property(background_sprite, "modulate:a", 0, duration)
    tween.parallel().tween_property(temp_sprite, "modulate:a", 1, duration)
    
    tween.finished.connect(func():
        background_sprite.texture = new_texture
        background_sprite.modulate.a = 1
        temp_sprite.queue_free()
        emit_signal("transition_completed")
    )

# 즉시 전환
func _instant_transition(new_texture: Texture2D):
    background_sprite.texture = new_texture
    emit_signal("transition_completed")

# 날씨 효과 설정
func set_weather(weather: Weather, transition_duration: float = 1.0):
    if weather == current_weather:
        return

    _stop_current_weather(transition_duration)
    current_weather = weather
    
    match weather:
        Weather.CLEAR:
            pass  # 모든 효과가 이미 중지됨
        Weather.RAIN:
            _start_rain(transition_duration)
        Weather.SNOW:
            _start_snow(transition_duration)
        Weather.FOG:
            _start_fog(transition_duration)

    emit_signal("effect_started")

# 현재 날씨 효과 중지
func _stop_current_weather(duration: float):
    var tween = create_tween()
    
    match current_weather:
        Weather.RAIN:
            tween.tween_property(rain_particles, "modulate:a", 0, duration)
            tween.tween_callback(func(): rain_particles.emitting = false)
        Weather.SNOW:
            tween.tween_property(snow_particles, "modulate:a", 0, duration)
            tween.tween_callback(func(): snow_particles.emitting = false)
        Weather.FOG:
            tween.tween_property(fog_particles, "modulate:a", 0, duration)
            tween.tween_callback(func(): fog_particles.emitting = false)

# 비 효과 시작
func _start_rain(duration: float):
    rain_particles.modulate.a = 0
    rain_particles.emitting = true
    var tween = create_tween()
    tween.tween_property(rain_particles, "modulate:a", 1, duration)

# 눈 효과 시작
func _start_snow(duration: float):
    snow_particles.modulate.a = 0
    snow_particles.emitting = true
    var tween = create_tween()
    tween.tween_property(snow_particles, "modulate:a", 1, duration)

# 안개 효과 시작
func _start_fog(duration: float):
    fog_particles.modulate.a = 0
    fog_particles.emitting = true
    var tween = create_tween()
    tween.tween_property(fog_particles, "modulate:a", 1, duration)

# 시간 설정
func set_time_of_day(time: TimeOfDay, transition_duration: float = 2.0):
    if time == current_time:
        return

    current_time = time
    var target_color: Color
    var target_alpha: float
    
    match time:
        TimeOfDay.DAY:
            target_color = Color(1, 1, 1, 0)
            target_alpha = 0
        TimeOfDay.SUNSET:
            target_color = Color(1, 0.5, 0.2, 0.3)
            target_alpha = 0.3
        TimeOfDay.NIGHT:
            target_color = Color(0, 0, 0.2, 0.5)
            target_alpha = 0.5
        TimeOfDay.SUNRISE:
            target_color = Color(1, 0.7, 0.4, 0.2)
            target_alpha = 0.2

    var tween = create_tween()
    tween.parallel().tween_property(time_overlay, "modulate", target_color, transition_duration)
    tween.parallel().tween_property(time_overlay, "modulate:a", target_alpha, transition_duration)
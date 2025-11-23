extends Node

class_name VisualDirector

signal effect_started(effect_name: String)
signal effect_completed(effect_name: String)
signal transition_completed(transition_name: String)

@export var default_transition_duration: float = 1.0
@export var default_character_move_duration: float = 0.8
@export var default_fade_duration: float = 0.5

var active_effects: Dictionary = {}
var camera_controller: Camera2D
var screen_overlay: ColorRect

func _ready() -> void:
	_setup_screen_overlay()

func _setup_screen_overlay() -> void:
	screen_overlay = ColorRect.new()
	screen_overlay.name = "ScreenOverlay"
	screen_overlay.color = Color.TRANSPARENT
	screen_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen_overlay)

# 캐릭터 등장 애니메이션
func character_enter(character_node: Node2D, entry_type: String, duration: float = -1) -> void:
	if duration < 0:
		duration = default_character_move_duration
	
	var target_pos = character_node.position
	var tween = create_tween()
	
	match entry_type:
		"slide_left":
			character_node.position.x = -200
			tween.tween_property(character_node, "position:x", target_pos.x, duration)
		"slide_right":
			character_node.position.x = get_viewport().get_visible_rect().size.x + 200
			tween.tween_property(character_node, "position:x", target_pos.x, duration)
		"slide_up":
			character_node.position.y = get_viewport().get_visible_rect().size.y + 200
			tween.tween_property(character_node, "position:y", target_pos.y, duration)
		"slide_down":
			character_node.position.y = -200
			tween.tween_property(character_node, "position:y", target_pos.y, duration)
		"fade_in":
			character_node.modulate.a = 0.0
			tween.tween_property(character_node, "modulate:a", 1.0, duration)
		"scale_in":
			character_node.scale = Vector2.ZERO
			tween.tween_property(character_node, "scale", Vector2.ONE, duration)
			tween.tween_property(character_node, "modulate:a", 1.0, duration)
		"bounce_in":
			character_node.scale = Vector2(0.1, 0.1)
			character_node.modulate.a = 0.8
			tween.tween_property(character_node, "scale", Vector2(1.2, 1.2), duration * 0.6)
			tween.tween_property(character_node, "scale", Vector2.ONE, duration * 0.4)
			tween.tween_property(character_node, "modulate:a", 1.0, duration)
		"instant":
			character_node.visible = true
			return
	
	character_node.visible = true
	emit_signal("effect_started", "character_enter_" + entry_type)
	await tween.finished
	emit_signal("effect_completed", "character_enter_" + entry_type)

# 캐릭터 퇴장 애니메이션
func character_exit(character_node: Node2D, exit_type: String, duration: float = -1) -> void:
	if duration < 0:
		duration = default_character_move_duration
	
	var tween = create_tween()
	
	match exit_type:
		"slide_left":
			tween.tween_property(character_node, "position:x", -200, duration)
		"slide_right":
			tween.tween_property(character_node, "position:x", get_viewport().get_visible_rect().size.x + 200, duration)
		"fade_out":
			tween.tween_property(character_node, "modulate:a", 0.0, duration)
		"scale_out":
			tween.tween_property(character_node, "scale", Vector2.ZERO, duration)
		"sink_down":
			tween.tween_property(character_node, "position:y", get_viewport().get_visible_rect().size.y + 200, duration)
			tween.tween_property(character_node, "modulate:a", 0.0, duration)
		"instant":
			character_node.visible = false
			return
	
	emit_signal("effect_started", "character_exit_" + exit_type)
	await tween.finished
	character_node.visible = false
	emit_signal("effect_completed", "character_exit_" + exit_type)

# 캐릭터 이동
func character_move(character_node: Node2D, target_position: Vector2, move_type: String, duration: float = -1) -> void:
	if duration < 0:
		duration = default_character_move_duration
	
	var tween = create_tween()
	
	match move_type:
		"linear":
			tween.tween_property(character_node, "position", target_position, duration)
		"ease_in_out":
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(character_node, "position", target_position, duration)
		"bounce":
			tween.set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(character_node, "position", target_position, duration)
		"elastic":
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.tween_property(character_node, "position", target_position, duration)
	
	emit_signal("effect_started", "character_move_" + move_type)
	await tween.finished
	emit_signal("effect_completed", "character_move_" + move_type)

# 화면 전환 효과
func screen_transition(transition_type: String, duration: float = -1) -> void:
	if duration < 0:
		duration = default_transition_duration
	
	var tween = create_tween()
	
	match transition_type:
		"fade_black":
			screen_overlay.color = Color.TRANSPARENT
			tween.tween_property(screen_overlay, "color", Color.BLACK, duration * 0.5)
			tween.tween_property(screen_overlay, "color", Color.TRANSPARENT, duration * 0.5)
		"fade_white":
			screen_overlay.color = Color.TRANSPARENT
			tween.tween_property(screen_overlay, "color", Color.WHITE, duration * 0.5)
			tween.tween_property(screen_overlay, "color", Color.TRANSPARENT, duration * 0.5)
		"fade_to_black":
			screen_overlay.color = Color.TRANSPARENT
			tween.tween_property(screen_overlay, "color", Color.BLACK, duration)
		"fade_from_black":
			screen_overlay.color = Color.BLACK
			tween.tween_property(screen_overlay, "color", Color.TRANSPARENT, duration)
		"flash_white":
			screen_overlay.color = Color.TRANSPARENT
			tween.tween_property(screen_overlay, "color", Color.WHITE, 0.1)
			tween.tween_property(screen_overlay, "color", Color.TRANSPARENT, duration - 0.1)
	
	emit_signal("effect_started", "screen_transition_" + transition_type)
	await tween.finished
	emit_signal("transition_completed", transition_type)

# 화면 쉐이크
func screen_shake(intensity: float, duration: float) -> void:
	if not camera_controller:
		return
	
	var original_position = camera_controller.global_position
	var tween = create_tween()
	
	emit_signal("effect_started", "screen_shake")
	
	for i in range(int(duration * 60)):  # 60 FPS 기준
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera_controller, "global_position", original_position + shake_offset, 1.0/60.0)
	
	tween.tween_property(camera_controller, "global_position", original_position, 0.1)
	await tween.finished
	emit_signal("effect_completed", "screen_shake")

# 화면 줌
func camera_zoom(zoom_level: Vector2, duration: float) -> void:
	if not camera_controller:
		return
	
	var tween = create_tween()
	tween.tween_property(camera_controller, "zoom", zoom_level, duration)
	
	emit_signal("effect_started", "camera_zoom")
	await tween.finished
	emit_signal("effect_completed", "camera_zoom")

# 배경 변경 (부드러운 전환)
func change_background(background_node: Node, new_texture: Texture2D, transition_type: String, duration: float = 1.0) -> void:
	match transition_type:
		"fade":
			var tween = create_tween()
			tween.tween_property(background_node, "modulate:a", 0.0, duration * 0.5)
			await tween.finished
			background_node.texture = new_texture
			tween = create_tween()
			tween.tween_property(background_node, "modulate:a", 1.0, duration * 0.5)
			await tween.finished
		"slide_left":
			var new_bg = Sprite2D.new()
			new_bg.texture = new_texture
			new_bg.position.x = get_viewport().get_visible_rect().size.x
			background_node.get_parent().add_child(new_bg)
			
			var tween = create_tween()
			tween.parallel().tween_property(background_node, "position:x", -get_viewport().get_visible_rect().size.x, duration)
			tween.parallel().tween_property(new_bg, "position:x", 0, duration)
			await tween.finished
			
			background_node.queue_free()
		"instant":
			background_node.texture = new_texture

# 텍스트 타이핑 효과
func typewriter_effect(label: Label, text: String, chars_per_second: float = 30.0) -> void:
	label.visible_ratio = 0.0
	label.text = text
	
	var total_chars = text.length()
	var duration = total_chars / chars_per_second
	
	var tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, duration)
	
	emit_signal("effect_started", "typewriter_effect")
	await tween.finished
	emit_signal("effect_completed", "typewriter_effect")

# 카메라 설정
func set_camera_controller(camera: Camera2D) -> void:
	camera_controller = camera

# 효과 중단
func stop_effect(effect_name: String) -> void:
	if active_effects.has(effect_name):
		var tween = active_effects[effect_name]
		if tween and tween.is_valid():
			tween.kill()
		active_effects.erase(effect_name)

# 모든 효과 중단
func stop_all_effects() -> void:
	for effect_name in active_effects.keys():
		stop_effect(effect_name)
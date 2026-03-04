extends CanvasLayer

# 캐릭터 초상화 시스템
# 캐릭터 포지셔닝, 전환 효과, 애니메이션을 관리

signal portrait_shown(character_id: String, position: String)
signal portrait_hidden(character_id: String)
signal portrait_moved(character_id: String, new_position: String)
signal transition_completed(character_id: String)

# 포트레이트 컨테이너
var portrait_container: Control
var portraits: Dictionary = {}  # {character_id: PortraitData}

# 포지션 프리셋
var position_presets: Dictionary = {
	"left": Vector2(0.15, 0.5),
	"center_left": Vector2(0.3, 0.5),
	"center": Vector2(0.5, 0.5),
	"center_right": Vector2(0.7, 0.5),
	"right": Vector2(0.85, 0.5),
	"far_left": Vector2(0.05, 0.5),
	"far_right": Vector2(0.95, 0.5)
}

# 전환 효과 설정
enum TransitionType {
	NONE,
	FADE,
	SLIDE_LEFT,
	SLIDE_RIGHT,
	SLIDE_UP,
	SLIDE_DOWN,
	ZOOM_IN,
	ZOOM_OUT,
	DISSOLVE
}

# 레이어 관리
var layer_count: int = 0
const MAX_LAYERS: int = 10

func _ready():
	_create_portrait_container()

# 포트레이트 컨테이너 생성
func _create_portrait_container() -> void:
	portrait_container = Control.new()
	portrait_container.name = "PortraitContainer"
	portrait_container.anchor_right = 1.0
	portrait_container.anchor_bottom = 1.0
	portrait_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait_container)

# 캐릭터 포트레이트 표시
func show_portrait(character_id: String, texture_path: String, position: String = "center", transition: int = TransitionType.FADE, duration: float = 0.5) -> void:
	if portraits.has(character_id):
		# 이미 표시된 경우 위치 또는 텍스처 업데이트
		update_portrait(character_id, texture_path, position, transition, duration)
		return
	
	# 새 포트레이트 생성
	var portrait_data = _create_portrait_data(character_id, texture_path, position)
	portraits[character_id] = portrait_data
	
	# 전환 효과 적용
	_apply_entrance_transition(portrait_data, transition, duration)
	
	emit_signal("portrait_shown", character_id, position)

# 포트레이트 업데이트
func update_portrait(character_id: String, texture_path: String, position: String = "", transition: int = TransitionType.FADE, duration: float = 0.3) -> void:
	if not portraits.has(character_id):
		show_portrait(character_id, texture_path, position if not position.is_empty() else "center", transition, duration)
		return
	
	var portrait_data = portraits[character_id]
	var new_texture = load(texture_path)
	
	if not new_texture:
		push_error("포트레이트 텍스처를 로드할 수 없습니다: " + texture_path)
		return
	
	# 텍스처 변경 (전환 효과와 함께)
	if transition != TransitionType.NONE:
		_crossfade_texture(portrait_data, new_texture, duration)
	else:
		portrait_data.texture_rect.texture = new_texture
	
	# 위치 변경
	if not position.is_empty() and position != portrait_data.current_position:
		move_portrait(character_id, position, duration)

# 포트레이트 이동
func move_portrait(character_id: String, new_position: String, duration: float = 0.5) -> void:
	if not portraits.has(character_id):
		return
	
	var portrait_data = portraits[character_id]
	var target_pos = _get_position_vector(new_position)
	
	if target_pos == Vector2.ZERO:
		push_error("알 수 없는 포지션: " + new_position)
		return
	
	portrait_data.current_position = new_position
	portrait_data.target_position = target_pos
	
	# 트윈 애니메이션
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(portrait_data.texture_rect, "anchor_left", target_pos.x, duration)
	tween.parallel().tween_property(portrait_data.texture_rect, "anchor_right", target_pos.x, duration)
	tween.parallel().tween_property(portrait_data.texture_rect, "anchor_top", target_pos.y, duration)
	tween.parallel().tween_property(portrait_data.texture_rect, "anchor_bottom", target_pos.y, duration)
	
	tween.tween_callback(func():
		emit_signal("portrait_moved", character_id, new_position)
	)

# 포트레이트 숨기기
func hide_portrait(character_id: String, transition: int = TransitionType.FADE, duration: float = 0.5) -> void:
	if not portraits.has(character_id):
		return
	
	var portrait_data = portraits[character_id]
	
	_apply_exit_transition(portrait_data, transition, duration)
	
	emit_signal("portrait_hidden", character_id)

# 포트레이트 제거 (즉시)
func remove_portrait(character_id: String) -> void:
	if not portraits.has(character_id):
		return
	
	var portrait_data = portraits[character_id]
	portrait_data.texture_rect.queue_free()
	portraits.erase(character_id)

# 모든 포트레이트 숨기기
func hide_all_portraits(transition: int = TransitionType.FADE, duration: float = 0.5) -> void:
	for character_id in portraits.keys():
		hide_portrait(character_id, transition, duration)

# 포트레이트 데이터 생성
func _create_portrait_data(character_id: String, texture_path: String, position: String) -> Dictionary:
	var texture = load(texture_path)
	if not texture:
		push_error("포트레이트 텍스처를 로드할 수 없습니다: " + texture_path)
		return {}
	
	var pos_vector = _get_position_vector(position)
	
	# TextureRect 생성
	var texture_rect = TextureRect.new()
	texture_rect.name = character_id
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.anchor_left = pos_vector.x
	texture_rect.anchor_right = pos_vector.x
	texture_rect.anchor_top = pos_vector.y
	texture_rect.anchor_bottom = pos_vector.y
	texture_rect.offset_left = -200  # 중심 정렬
	texture_rect.offset_right = 200
	texture_rect.offset_top = -300
	texture_rect.offset_bottom = 300
	texture_rect.z_index = layer_count
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	layer_count = (layer_count + 1) % MAX_LAYERS
	
	portrait_container.add_child(texture_rect)
	
	return {
		"character_id": character_id,
		"texture_rect": texture_rect,
		"texture_path": texture_path,
		"current_position": position,
		"target_position": pos_vector,
		"z_index": texture_rect.z_index
	}

# 진입 전환 효과
func _apply_entrance_transition(portrait_data: Dictionary, transition: int, duration: float) -> void:
	var texture_rect: TextureRect = portrait_data.texture_rect
	
	match transition:
		TransitionType.FADE:
			texture_rect.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(texture_rect, "modulate:a", 1.0, duration)
		
		TransitionType.SLIDE_LEFT:
			var original_anchor = texture_rect.anchor_left
			texture_rect.anchor_left = 1.5
			texture_rect.anchor_right = 1.5
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(texture_rect, "anchor_left", original_anchor, duration)
			tween.parallel().tween_property(texture_rect, "anchor_right", original_anchor, duration)
		
		TransitionType.SLIDE_RIGHT:
			var original_anchor = texture_rect.anchor_left
			texture_rect.anchor_left = -0.5
			texture_rect.anchor_right = -0.5
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(texture_rect, "anchor_left", original_anchor, duration)
			tween.parallel().tween_property(texture_rect, "anchor_right", original_anchor, duration)
		
		TransitionType.ZOOM_IN:
			texture_rect.scale = Vector2(0.1, 0.1)
			texture_rect.modulate.a = 0.0
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(texture_rect, "scale", Vector2(1.0, 1.0), duration)
			tween.parallel().tween_property(texture_rect, "modulate:a", 1.0, duration)
		
		TransitionType.DISSOLVE:
			texture_rect.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(texture_rect, "modulate:a", 1.0, duration)
		
		_:
			# NONE 또는 기본
			pass
	
	# 완료 시그널
	await get_tree().create_timer(duration).timeout
	emit_signal("transition_completed", portrait_data.character_id)

# 퇴장 전환 효과
func _apply_exit_transition(portrait_data: Dictionary, transition: int, duration: float) -> void:
	var texture_rect: TextureRect = portrait_data.texture_rect
	
	match transition:
		TransitionType.FADE:
			var tween = create_tween()
			tween.tween_property(texture_rect, "modulate:a", 0.0, duration)
		
		TransitionType.SLIDE_LEFT:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(texture_rect, "anchor_left", -0.5, duration)
			tween.parallel().tween_property(texture_rect, "anchor_right", -0.5, duration)
		
		TransitionType.SLIDE_RIGHT:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(texture_rect, "anchor_left", 1.5, duration)
			tween.parallel().tween_property(texture_rect, "anchor_right", 1.5, duration)
		
		TransitionType.ZOOM_OUT:
			var tween = create_tween()
			tween.set_ease(Tween.EASE_IN)
			tween.tween_property(texture_rect, "scale", Vector2(0.1, 0.1), duration)
			tween.parallel().tween_property(texture_rect, "modulate:a", 0.0, duration)
		
		TransitionType.DISSOLVE:
			var tween = create_tween()
			tween.tween_property(texture_rect, "modulate:a", 0.0, duration)
		
		_:
			# NONE 또는 기본
			pass
	
	# 완료 후 제거
	await get_tree().create_timer(duration).timeout
	remove_portrait(portrait_data.character_id)

# 텍스처 크로스페이드
func _crossfade_texture(portrait_data: Dictionary, new_texture: Texture2D, duration: float) -> void:
	var old_texture_rect: TextureRect = portrait_data.texture_rect
	
	# 새 TextureRect 생성
	var new_texture_rect = TextureRect.new()
	new_texture_rect.texture = new_texture
	new_texture_rect.expand_mode = old_texture_rect.expand_mode
	new_texture_rect.stretch_mode = old_texture_rect.stretch_mode
	new_texture_rect.anchor_left = old_texture_rect.anchor_left
	new_texture_rect.anchor_right = old_texture_rect.anchor_right
	new_texture_rect.anchor_top = old_texture_rect.anchor_top
	new_texture_rect.anchor_bottom = old_texture_rect.anchor_bottom
	new_texture_rect.offset_left = old_texture_rect.offset_left
	new_texture_rect.offset_right = old_texture_rect.offset_right
	new_texture_rect.offset_top = old_texture_rect.offset_top
	new_texture_rect.offset_bottom = old_texture_rect.offset_bottom
	new_texture_rect.z_index = old_texture_rect.z_index + 1
	new_texture_rect.modulate.a = 0.0
	new_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	portrait_container.add_child(new_texture_rect)
	
	# 크로스페이드 애니메이션
	var tween = create_tween()
	tween.tween_property(old_texture_rect, "modulate:a", 0.0, duration / 2)
	tween.parallel().tween_property(new_texture_rect, "modulate:a", 1.0, duration / 2)
	
	await tween.finished
	
	# 이전 텍스처 제거
	old_texture_rect.queue_free()
	portrait_data.texture_rect = new_texture_rect
	portrait_data.texture_path = new_texture.resource_path

# 포지션 벡터 가져오기
func _get_position_vector(position_name: String) -> Vector2:
	if position_presets.has(position_name.to_lower()):
		return position_presets[position_name.to_lower()]
	
	# "x,y" 형식의 커스텀 포지션
	if "," in position_name:
		var coords = position_name.split(",")
		if coords.size() == 2:
			return Vector2(coords[0].to_float(), coords[1].to_float())
	
	return Vector2(0.5, 0.5)  # 기본값: 중앙

# 레이어 순서 변경
func set_portrait_layer(character_id: String, layer: int) -> void:
	if not portraits.has(character_id):
		return
	
	var portrait_data = portraits[character_id]
	portrait_data.texture_rect.z_index = clamp(layer, 0, MAX_LAYERS - 1)
	portrait_data.z_index = portrait_data.texture_rect.z_index

# 흔들기 효과
func shake_portrait(character_id: String, intensity: float = 10.0, duration: float = 0.5) -> void:
	if not portraits.has(character_id):
		return
	
	var portrait_data = portraits[character_id]
	var texture_rect: TextureRect = portrait_data.texture_rect
	var original_position = texture_rect.position
	
	var tween = create_tween()
	for i in range(int(duration * 20)):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(texture_rect, "position", original_position + offset, 0.05)
		intensity *= 0.9  # 점진적으로 감소
	
	tween.tween_property(texture_rect, "position", original_position, 0.05)

# 점프 효과
func bounce_portrait(character_id: String, height: float = 30.0, duration: float = 0.5) -> void:
	if not portraits.has(character_id):
		return
	
	var portrait_data = portraits[character_id]
	var texture_rect: TextureRect = portrait_data.texture_rect
	var original_offset_top = texture_rect.offset_top
	var original_offset_bottom = texture_rect.offset_bottom
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(texture_rect, "offset_top", original_offset_top - height, duration / 2)
	tween.parallel().tween_property(texture_rect, "offset_bottom", original_offset_bottom - height, duration / 2)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(texture_rect, "offset_top", original_offset_top, duration / 2)
	tween.parallel().tween_property(texture_rect, "offset_bottom", original_offset_bottom, duration / 2)

# 포트레이트 정보 가져오기
func get_portrait_info(character_id: String) -> Dictionary:
	if not portraits.has(character_id):
		return {}
	
	return portraits[character_id].duplicate(true)

# 활성 포트레이트 목록
func get_active_portraits() -> Array:
	return portraits.keys()

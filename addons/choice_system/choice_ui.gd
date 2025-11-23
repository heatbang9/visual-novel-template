extends Control

class_name ChoiceUI

signal choice_selected(choice_id: String)

@export var choice_button_scene: PackedScene = preload("res://scenes/ui/choice_button.tscn")
@export var choice_container: VBoxContainer
@export var animation_player: AnimationPlayer

var current_choices: Array = []
var choice_buttons: Array[Button] = []

func _ready() -> void:
	if choice_container == null:
		choice_container = VBoxContainer.new()
		add_child(choice_container)
	
	if animation_player == null:
		animation_player = AnimationPlayer.new()
		add_child(animation_player)
		_create_animations()

# 선택지 표시
func show_choices(choices: Array) -> void:
	_clear_choices()
	current_choices = choices
	
	for i in range(choices.size()):
		var choice = choices[i]
		var button = _create_choice_button(choice, i)
		choice_container.add_child(button)
		choice_buttons.append(button)
	
	_animate_show()

# 선택지 숨기기
func hide_choices() -> void:
	_animate_hide()

# 선택지 버튼 생성
func _create_choice_button(choice: Dictionary, index: int) -> Button:
	var button: Button
	
	if choice_button_scene:
		button = choice_button_scene.instantiate()
	else:
		button = Button.new()
	
	button.text = choice.get("text", "Choice " + str(index + 1))
	button.name = "Choice" + str(index)
	
	# 선택지 ID 저장
	var choice_id = choice.get("id", "choice_" + str(index))
	button.set_meta("choice_id", choice_id)
	
	# 요구사항 확인하여 버튼 활성화/비활성화
	var requirements_met = choice.get("requirements_met", true)
	button.disabled = not requirements_met
	
	# 시그널 연결
	button.pressed.connect(_on_choice_button_pressed.bind(choice_id))
	
	# 스타일링
	_apply_choice_styling(button, choice, requirements_met)
	
	return button

# 선택지 버튼 스타일링
func _apply_choice_styling(button: Button, choice: Dictionary, requirements_met: bool) -> void:
	if not requirements_met:
		button.modulate = Color(0.5, 0.5, 0.5, 0.7)  # 회색으로 표시
		if button.has_method("set_tooltip_text"):
			button.tooltip_text = "요구 조건이 충족되지 않았습니다."
	else:
		button.modulate = Color.WHITE
	
	# 효과에 따른 색상 표시 (선택적)
	var effects = choice.get("effects", [])
	for effect in effects:
		var variable = effect.get("variable", "")
		var value = effect.get("value", 0)
		
		if variable == "affection_level" and value > 0:
			button.modulate = Color(1.0, 0.8, 0.8)  # 연한 빨강 (애정도 상승)
		elif variable == "friendship_level" and value > 0:
			button.modulate = Color(0.8, 0.8, 1.0)  # 연한 파랑 (우정도 상승)

# 선택지 버튼 클릭 처리
func _on_choice_button_pressed(choice_id: String) -> void:
	# 버튼 비활성화
	for button in choice_buttons:
		button.disabled = true
	
	emit_signal("choice_selected", choice_id)
	hide_choices()

# 선택지 정리
func _clear_choices() -> void:
	for button in choice_buttons:
		if is_instance_valid(button):
			button.queue_free()
	choice_buttons.clear()
	current_choices.clear()

# 애니메이션 생성
func _create_animations() -> void:
	if not animation_player:
		return
	
	var animation_library = AnimationLibrary.new()
	
	# 나타나기 애니메이션
	var show_anim = Animation.new()
	show_anim.length = 0.3
	show_anim.step = 0.01
	
	var track_index = show_anim.add_track(Animation.TYPE_VALUE)
	show_anim.track_set_path(track_index, ".:modulate:a")
	show_anim.track_insert_key(track_index, 0.0, 0.0)
	show_anim.track_insert_key(track_index, 0.3, 1.0)
	
	var scale_track = show_anim.add_track(Animation.TYPE_VALUE)
	show_anim.track_set_path(scale_track, ".:scale")
	show_anim.track_insert_key(scale_track, 0.0, Vector2(0.8, 0.8))
	show_anim.track_insert_key(scale_track, 0.3, Vector2(1.0, 1.0))
	
	animation_library.add_animation("show", show_anim)
	
	# 사라지기 애니메이션
	var hide_anim = Animation.new()
	hide_anim.length = 0.2
	hide_anim.step = 0.01
	
	var hide_track_index = hide_anim.add_track(Animation.TYPE_VALUE)
	hide_anim.track_set_path(hide_track_index, ".:modulate:a")
	hide_anim.track_insert_key(hide_track_index, 0.0, 1.0)
	hide_anim.track_insert_key(hide_track_index, 0.2, 0.0)
	
	var hide_scale_track = hide_anim.add_track(Animation.TYPE_VALUE)
	hide_anim.track_set_path(hide_scale_track, ".:scale")
	hide_anim.track_insert_key(hide_scale_track, 0.0, Vector2(1.0, 1.0))
	hide_anim.track_insert_key(hide_scale_track, 0.2, Vector2(0.9, 0.9))
	
	animation_library.add_animation("hide", hide_anim)
	
	animation_player.add_animation_library("default", animation_library)

# 애니메이션 재생
func _animate_show() -> void:
	visible = true
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	
	if animation_player and animation_player.has_animation("default/show"):
		animation_player.play("default/show")

func _animate_hide() -> void:
	if animation_player and animation_player.has_animation("default/hide"):
		animation_player.play("default/hide")
		await animation_player.animation_finished
	
	visible = false
	_clear_choices()

# 특정 선택지 활성화/비활성화
func set_choice_enabled(choice_id: String, enabled: bool) -> void:
	for button in choice_buttons:
		if button.get_meta("choice_id", "") == choice_id:
			button.disabled = not enabled
			break

# 선택지 텍스트 업데이트
func update_choice_text(choice_id: String, new_text: String) -> void:
	for button in choice_buttons:
		if button.get_meta("choice_id", "") == choice_id:
			button.text = new_text
			break

# 현재 활성화된 선택지들 가져오기
func get_available_choices() -> Array:
	var available = []
	for i in range(choice_buttons.size()):
		var button = choice_buttons[i]
		if not button.disabled:
			available.append(current_choices[i])
	return available
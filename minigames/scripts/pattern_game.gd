extends MinigameBase

var pattern_sequence: Array[int] = []
var player_sequence: Array[int] = []
var pattern_buttons: Array[Button] = []
var display_index: int = 0
var is_showing_pattern: bool = false
var pattern_length: int = 4

func _ready() -> void:
	game_name = "패턴 따라하기"
	game_description = "순서대로 버튼을 클릭하세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	pattern_length = 4 + difficulty
	
	for i in range(4):
		var button = Button.new()
		button.size = Vector2(100, 100)
		button.position = Vector2(150 + i * 120, 200)
		button.text = str(i + 1)
		button.pressed.connect(_on_pattern_button_pressed.bind(i))
		pattern_buttons.append(button)
		game_layer.add_child(button)

func on_game_start() -> void:
	generate_pattern()
	show_pattern()

func generate_pattern() -> void:
	pattern_sequence.clear()
	for i in range(pattern_length):
		pattern_sequence.append(randi() % 4)

func show_pattern() -> void:
	is_showing_pattern = true
	player_sequence.clear()
	display_index = 0
	
	for button in pattern_buttons:
		button.disabled = true
	
	_show_next_in_pattern()

func _show_next_in_pattern() -> void:
	if display_index >= pattern_sequence.size():
		_pattern_display_complete()
		return
	
	var button_index = pattern_sequence[display_index]
	pattern_buttons[button_index].modulate = Color.YELLOW
	await get_tree().create_timer(0.6).timeout
	pattern_buttons[button_index].modulate = Color.WHITE
	await get_tree().create_timer(0.4).timeout
	
	display_index += 1
	_show_next_in_pattern()

func _pattern_display_complete() -> void:
	is_showing_pattern = false
	for button in pattern_buttons:
		button.disabled = false

func _on_pattern_button_pressed(button_index: int) -> void:
	if not is_game_active or is_showing_pattern:
		return
	
	player_sequence.append(button_index)
	
	var current_index = player_sequence.size() - 1
	if player_sequence[current_index] != pattern_sequence[current_index]:
		end_game(false)
		return
	
	if player_sequence.size() == pattern_sequence.size():
		update_score(current_score + 20)
		end_game(true)
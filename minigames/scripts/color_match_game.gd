extends MinigameBase

var color_sequence: Array[Color] = []
var player_sequence: Array[Color] = []
var available_colors: Array[Color] = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW]
var color_buttons: Array[Button] = []
var display_panel: Panel
var sequence_length: int = 3
var current_display_index: int = 0
var is_displaying: bool = false

func _ready() -> void:
	game_name = "색깔 매칭"
	game_description = "색상 순서를 기억하고 따라하세요!"
	time_limit = 45.0
	super._ready()

func setup_game() -> void:
	sequence_length = 3 + difficulty
	
	display_panel = Panel.new()
	display_panel.size = Vector2(200, 200)
	display_panel.position = Vector2(get_viewport().size.x / 2 - 100, 50)
	game_layer.add_child(display_panel)
	
	for i in range(available_colors.size()):
		var button = Button.new()
		button.size = Vector2(80, 80)
		button.position = Vector2(50 + i * 90, get_viewport().size.y - 150)
		button.modulate = available_colors[i]
		button.pressed.connect(_on_color_button_pressed.bind(i))
		color_buttons.append(button)
		game_layer.add_child(button)

func on_game_start() -> void:
	generate_sequence()
	display_sequence()

func generate_sequence() -> void:
	color_sequence.clear()
	for i in range(sequence_length):
		color_sequence.append(available_colors[randi() % available_colors.size()])

func display_sequence() -> void:
	is_displaying = true
	player_sequence.clear()
	current_display_index = 0
	
	for button in color_buttons:
		button.disabled = true
	
	_display_next_color()

func _display_next_color() -> void:
	if current_display_index >= color_sequence.size():
		_end_display()
		return
	
	display_panel.modulate = color_sequence[current_display_index]
	await get_tree().create_timer(0.8).timeout
	display_panel.modulate = Color.WHITE
	await get_tree().create_timer(0.4).timeout
	
	current_display_index += 1
	_display_next_color()

func _end_display() -> void:
	is_displaying = false
	for button in color_buttons:
		button.disabled = false

func _on_color_button_pressed(color_index: int) -> void:
	if not is_game_active or is_displaying:
		return
	
	var selected_color = available_colors[color_index]
	player_sequence.append(selected_color)
	
	if player_sequence.size() > color_sequence.size():
		end_game(false)
		return
	
	var current_index = player_sequence.size() - 1
	if player_sequence[current_index] != color_sequence[current_index]:
		end_game(false)
		return
	
	if player_sequence.size() == color_sequence.size():
		update_score(current_score + 10 * difficulty)
		end_game(true)
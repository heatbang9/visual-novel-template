extends MinigameBase

var grid_size: int = 3
var puzzle_pieces: Array[Button] = []
var correct_positions: Array[int] = []
var current_positions: Array[int] = []
var empty_index: int = 8

func _ready() -> void:
	game_name = "퍼즐 조각 맞추기"
	game_description = "숫자를 올바른 순서로 배열하세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	grid_size = 3
	if difficulty > 2:
		grid_size = 4
	
	empty_index = grid_size * grid_size - 1
	
	for i in range(grid_size * grid_size):
		correct_positions.append(i)
	
	current_positions = correct_positions.duplicate()
	
	create_puzzle_grid()
	shuffle_puzzle()

func create_puzzle_grid() -> void:
	var button_size = 60
	var spacing = 10
	var start_x = (get_viewport().size.x - (grid_size * (button_size + spacing) - spacing)) / 2
	var start_y = 100
	
	for i in range(grid_size * grid_size):
		var button = Button.new()
		button.size = Vector2(button_size, button_size)
		
		var row = i / grid_size
		var col = i % grid_size
		button.position = Vector2(
			start_x + col * (button_size + spacing),
			start_y + row * (button_size + spacing)
		)
		
		if i == empty_index:
			button.text = ""
			button.disabled = true
		else:
			button.text = str(i + 1)
		
		button.pressed.connect(_on_puzzle_piece_clicked.bind(i))
		puzzle_pieces.append(button)
		game_layer.add_child(button)

func shuffle_puzzle() -> void:
	for i in range(100):
		var possible_moves = get_possible_moves()
		if possible_moves.size() > 0:
			var random_move = possible_moves[randi() % possible_moves.size()]
			swap_pieces(empty_index, random_move)

func get_possible_moves() -> Array[int]:
	var moves: Array[int] = []
	var row = empty_index / grid_size
	var col = empty_index % grid_size
	
	if row > 0: moves.append(empty_index - grid_size)
	if row < grid_size - 1: moves.append(empty_index + grid_size)
	if col > 0: moves.append(empty_index - 1)
	if col < grid_size - 1: moves.append(empty_index + 1)
	
	return moves

func _on_puzzle_piece_clicked(piece_index: int) -> void:
	if not is_game_active:
		return
	
	var possible_moves = get_possible_moves()
	if piece_index in possible_moves:
		swap_pieces(empty_index, piece_index)
		
		if check_win_condition():
			update_score(current_score + 50)
			end_game(true)

func swap_pieces(index1: int, index2: int) -> void:
	var temp_text = puzzle_pieces[index1].text
	var temp_disabled = puzzle_pieces[index1].disabled
	
	puzzle_pieces[index1].text = puzzle_pieces[index2].text
	puzzle_pieces[index1].disabled = puzzle_pieces[index2].disabled
	
	puzzle_pieces[index2].text = temp_text
	puzzle_pieces[index2].disabled = temp_disabled
	
	empty_index = index2

func check_win_condition() -> bool:
	for i in range(grid_size * grid_size - 1):
		if puzzle_pieces[i].text != str(i + 1):
			return false
	return puzzle_pieces[empty_index].text == ""
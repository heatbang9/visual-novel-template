extends MinigameBase

var puzzle_pieces: Array[ColorRect] = []
var target_rotations: Array[float] = []
var current_rotations: Array[float] = []
var grid_size: int = 3

func _ready() -> void:
	game_name = "돌리기 퍼즐"
	game_description = "모든 조각을 올바른 방향으로 돌리세요!"
	time_limit = 90.0
	super._ready()

func setup_game() -> void:
	grid_size = 3 + (difficulty - 1)
	create_puzzle_grid()
	shuffle_rotations()

func create_puzzle_grid() -> void:
	var piece_size = 60
	var spacing = 10
	var start_x = (get_viewport().size.x - (grid_size * (piece_size + spacing) - spacing)) / 2
	var start_y = 150
	
	for i in range(grid_size * grid_size):
		var piece = ColorRect.new()
		piece.size = Vector2(piece_size, piece_size)
		var row = i / grid_size
		var col = i % grid_size
		piece.position = Vector2(
			start_x + col * (piece_size + spacing),
			start_y + row * (piece_size + spacing)
		)
		piece.color = Color.CYAN
		
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = piece.size
		collision.shape = rect_shape
		area.add_child(collision)
		area.position = piece.position + piece.size / 2
		area.input_event.connect(_on_piece_clicked.bind(i))
		
		target_rotations.append(0)
		current_rotations.append(0)
		puzzle_pieces.append(piece)
		game_layer.add_child(piece)
		game_layer.add_child(area)

func shuffle_rotations() -> void:
	for i in range(puzzle_pieces.size()):
		var random_rotation = (randi() % 4) * 90
		current_rotations[i] = random_rotation
		puzzle_pieces[i].rotation_degrees = random_rotation

func _on_piece_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, piece_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_game_active:
			return
		
		current_rotations[piece_index] += 90
		if current_rotations[piece_index] >= 360:
			current_rotations[piece_index] = 0
		
		puzzle_pieces[piece_index].rotation_degrees = current_rotations[piece_index]
		check_win_condition()

func check_win_condition() -> bool:
	for i in range(current_rotations.size()):
		if current_rotations[i] != target_rotations[i]:
			return false
	
	update_score(current_score + 75)
	end_game(true)
	return true
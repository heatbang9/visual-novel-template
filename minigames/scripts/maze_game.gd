extends MinigameBase

var maze_grid: Array = []
var player: ColorRect
var exit_point: ColorRect
var grid_size: int = 15
var cell_size: int = 20
var player_pos: Vector2i = Vector2i(1, 1)

func _ready() -> void:
	game_name = "미로 탈출"
	game_description = "화살표 키로 미로를 탈출하세요!"
	time_limit = 120.0
	super._ready()

func setup_game() -> void:
	grid_size = 13 + difficulty * 2
	cell_size = min(20, int(400 / grid_size))
	generate_maze()
	create_player()
	create_exit()

func generate_maze() -> void:
	maze_grid = []
	for y in range(grid_size):
		var row = []
		for x in range(grid_size):
			if x == 0 or y == 0 or x == grid_size - 1 or y == grid_size - 1:
				row.append(1)
			elif x % 2 == 0 and y % 2 == 0:
				row.append(1)
			else:
				row.append(0)
		maze_grid.append(row)
	
	for y in range(2, grid_size - 1, 2):
		for x in range(2, grid_size - 1, 2):
			var directions = [[0, -1], [1, 0], [0, 1], [-1, 0]]
			directions.shuffle()
			for dir in directions:
				var nx = x + dir[0]
				var ny = y + dir[1]
				if nx >= 0 and nx < grid_size and ny >= 0 and ny < grid_size:
					if maze_grid[ny][nx] == 0:
						maze_grid[y + dir[1]][x + dir[0]] = 1
						break
	
	draw_maze()

func draw_maze() -> void:
	var start_x = (get_viewport().size.x - grid_size * cell_size) / 2
	var start_y = 120
	
	for y in range(grid_size):
		for x in range(grid_size):
			if maze_grid[y][x] == 1:
				var wall = ColorRect.new()
				wall.size = Vector2(cell_size, cell_size)
				wall.position = Vector2(start_x + x * cell_size, start_y + y * cell_size)
				wall.color = Color.GRAY
				game_layer.add_child(wall)

func create_player() -> void:
	player = ColorRect.new()
	player.size = Vector2(cell_size - 2, cell_size - 2)
	player.color = Color.BLUE
	update_player_position()
	game_layer.add_child(player)

func create_exit() -> void:
	exit_point = ColorRect.new()
	exit_point.size = Vector2(cell_size - 2, cell_size - 2)
	exit_point.color = Color.GREEN
	var start_x = (get_viewport().size.x - grid_size * cell_size) / 2
	var start_y = 120
	exit_point.position = Vector2(
		start_x + (grid_size - 2) * cell_size + 1,
		start_y + (grid_size - 2) * cell_size + 1
	)
	game_layer.add_child(exit_point)

func update_player_position() -> void:
	var start_x = (get_viewport().size.x - grid_size * cell_size) / 2
	var start_y = 120
	player.position = Vector2(
		start_x + player_pos.x * cell_size + 1,
		start_y + player_pos.y * cell_size + 1
	)

func _input(event: InputEvent) -> void:
	if not is_game_active:
		return
	
	if event is InputEventKey and event.pressed:
		var new_pos = player_pos
		match event.keycode:
			KEY_UP:
				new_pos.y -= 1
			KEY_DOWN:
				new_pos.y += 1
			KEY_LEFT:
				new_pos.x -= 1
			KEY_RIGHT:
				new_pos.x += 1
		
		if can_move_to(new_pos):
			player_pos = new_pos
			update_player_position()
			check_win()

func can_move_to(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= grid_size or pos.y < 0 or pos.y >= grid_size:
		return false
	return maze_grid[pos.y][pos.x] == 0

func check_win() -> void:
	if player_pos.x == grid_size - 2 and player_pos.y == grid_size - 2:
		update_score(current_score + 100)
		end_game(true)
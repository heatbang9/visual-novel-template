extends MinigameBase

var player_pos: Vector2i = Vector2i(1, 1)
var dungeon_map: Array[Array] = []
var player_sprite: ColorRect
var treasures_found: int = 0
var total_treasures: int = 5
var enemies: Array[Vector2i] = []
var map_size: int = 15

func _ready() -> void:
	game_name_key = "dungeon_crawler_name"
	game_desc_key = "dungeon_crawler_desc"
	time_limit = 180.0
	super._ready()

func setup_game() -> void:
	map_size = 12 + difficulty * 2
	total_treasures = 3 + difficulty
	generate_random_dungeon()
	create_player()
	spawn_treasures_and_enemies()

func generate_random_dungeon() -> void:
	dungeon_map = []
	for y in range(map_size):
		var row = []
		for x in range(map_size):
			if x == 0 or y == 0 or x == map_size - 1 or y == map_size - 1:
				row.append(1)
			elif get_random_int(0, 100) < 30:
				row.append(1)
			else:
				row.append(0)
		dungeon_map.append(row)
	
	dungeon_map[1][1] = 0
	draw_dungeon()

func draw_dungeon() -> void:
	var cell_size = min(20, int(400 / map_size))
	var start_x = 50
	var start_y = 120
	
	for y in range(map_size):
		for x in range(map_size):
			if dungeon_map[y][x] == 1:
				var wall = ColorRect.new()
				wall.size = Vector2(cell_size, cell_size)
				wall.position = Vector2(start_x + x * cell_size, start_y + y * cell_size)
				wall.color = Color.GRAY
				game_layer.add_child(wall)

func create_player() -> void:
	player_sprite = ColorRect.new()
	player_sprite.size = Vector2(18, 18)
	player_sprite.color = Color.BLUE
	update_player_position()
	game_layer.add_child(player_sprite)

func spawn_treasures_and_enemies() -> void:
	var spawned_treasures = 0
	var spawned_enemies = 0
	var max_enemies = difficulty + 2
	
	for attempt in range(100):
		var x = get_random_int(1, map_size - 2)
		var y = get_random_int(1, map_size - 2)
		
		if dungeon_map[y][x] == 0 and Vector2i(x, y) != player_pos:
			if spawned_treasures < total_treasures and get_random_int(0, 1):
				create_treasure(Vector2i(x, y))
				spawned_treasures += 1
			elif spawned_enemies < max_enemies:
				create_enemy(Vector2i(x, y))
				spawned_enemies += 1
		
		if spawned_treasures >= total_treasures and spawned_enemies >= max_enemies:
			break

func create_treasure(pos: Vector2i) -> void:
	var cell_size = min(20, int(400 / map_size))
	var treasure = ColorRect.new()
	treasure.size = Vector2(cell_size - 2, cell_size - 2)
	treasure.position = Vector2(51 + pos.x * cell_size, 121 + pos.y * cell_size)
	treasure.color = Color.YELLOW
	treasure.name = "Treasure_%d_%d" % [pos.x, pos.y]
	game_layer.add_child(treasure)

func create_enemy(pos: Vector2i) -> void:
	var cell_size = min(20, int(400 / map_size))
	var enemy = ColorRect.new()
	enemy.size = Vector2(cell_size - 2, cell_size - 2)
	enemy.position = Vector2(51 + pos.x * cell_size, 121 + pos.y * cell_size)
	enemy.color = Color.RED
	enemy.name = "Enemy_%d_%d" % [pos.x, pos.y]
	enemies.append(pos)
	game_layer.add_child(enemy)

func update_player_position() -> void:
	var cell_size = min(20, int(400 / map_size))
	player_sprite.position = Vector2(
		51 + player_pos.x * cell_size,
		121 + player_pos.y * cell_size
	)

func _input(event: InputEvent) -> void:
	if not is_game_active:
		return
	
	if event is InputEventKey and event.pressed:
		var new_pos = player_pos
		match event.keycode:
			KEY_UP, KEY_W:
				new_pos.y -= 1
			KEY_DOWN, KEY_S:
				new_pos.y += 1
			KEY_LEFT, KEY_A:
				new_pos.x -= 1
			KEY_RIGHT, KEY_D:
				new_pos.x += 1
		
		if can_move_to(new_pos):
			player_pos = new_pos
			update_player_position()
			check_interactions()

func can_move_to(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= map_size or pos.y < 0 or pos.y >= map_size:
		return false
	return dungeon_map[pos.y][pos.x] == 0

func check_interactions() -> void:
	var treasure_name = "Treasure_%d_%d" % [player_pos.x, player_pos.y]
	var treasure = game_layer.get_node_or_null(treasure_name)
	if treasure:
		treasure.queue_free()
		treasures_found += 1
		update_score(current_score + 20)
		
		if treasures_found >= total_treasures:
			end_game(true)
	
	if player_pos in enemies:
		if get_random_int(0, 100) < 30:
			end_game(false)
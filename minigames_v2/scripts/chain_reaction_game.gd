extends MinigameBase

var game_state: Dictionary = {}
var entities: Array[Dictionary] = []
var objectives_completed: int = 0
var total_objectives: int = 5

func _ready() -> void:
	game_name_key = "chain_reaction_name"
	game_desc_key = "chain_reaction_desc"
	time_limit = 90.0 + difficulty * 15.0
	super._ready()

func setup_game() -> void:
	total_objectives = 3 + difficulty
	initialize_game_specific()
	create_game_ui()

func initialize_game_specific() -> void:
	match "chain_reaction":
		"route_finder":
			setup_route_finding()
		"chain_reaction":
			setup_chain_system()
		"grid_control":
			setup_grid_system()
		_:
			setup_generic_game()

func setup_route_finding() -> void:
	var grid_size = 8 + difficulty
	for i in range(grid_size):
		var row = []
		for j in range(grid_size):
			row.append(get_random_int(0, 1))
		entities.append({"type": "cell", "data": row})

func setup_chain_system() -> void:
	for i in range(10 + difficulty * 3):
		entities.append({
			"type": "node",
			"x": get_random_int(50, 500),
			"y": get_random_int(150, 400),
			"active": false,
			"connections": []
		})

func setup_grid_system() -> void:
	var size = 6 + difficulty
	for i in range(size * size):
		entities.append({
			"type": "grid_cell",
			"index": i,
			"owned": false,
			"value": get_random_int(1, 5)
		})

func setup_generic_game() -> void:
	for i in range(5 + difficulty * 2):
		entities.append({
			"type": "generic",
			"value": get_random_int(1, 10),
			"active": false
		})

func create_game_ui() -> void:
	var info_label = Label.new()
	info_label.text = "목표: %d/%d 완성" % [objectives_completed, total_objectives]
	info_label.position = Vector2(50, 100)
	info_label.size = Vector2(300, 30)
	info_label.name = "InfoLabel"
	game_layer.add_child(info_label)
	
	create_specific_ui()

func create_specific_ui() -> void:
	match "chain_reaction":
		"route_finder":
			create_route_ui()
		"chain_reaction":
			create_chain_ui()
		_:
			create_generic_ui()

func create_route_ui() -> void:
	for i in range(entities.size()):
		var entity = entities[i]
		if entity.type == "cell":
			for j in range(entity.data.size()):
				var button = Button.new()
				button.size = Vector2(30, 30)
				button.position = Vector2(50 + j * 35, 150 + i * 35)
				button.modulate = Color.WHITE if entity.data[j] == 0 else Color.GRAY
				button.pressed.connect(_on_route_cell_clicked.bind(i, j))
				game_layer.add_child(button)

func create_chain_ui() -> void:
	for i in range(entities.size()):
		var entity = entities[i]
		if entity.type == "node":
			var button = Button.new()
			button.size = Vector2(20, 20)
			button.position = Vector2(entity.x, entity.y)
			button.modulate = Color.RED if not entity.active else Color.GREEN
			button.pressed.connect(_on_node_clicked.bind(i))
			game_layer.add_child(button)

func create_generic_ui() -> void:
	for i in range(min(entities.size(), 10)):
		var button = Button.new()
		button.text = str(entities[i].value)
		button.size = Vector2(50, 30)
		button.position = Vector2(50 + (i % 5) * 60, 200 + (i / 5) * 40)
		button.pressed.connect(_on_generic_clicked.bind(i))
		game_layer.add_child(button)

func _on_route_cell_clicked(row: int, col: int) -> void:
	if entities[row].data[col] == 0:
		objectives_completed += 1
		update_objectives()

func _on_node_clicked(index: int) -> void:
	entities[index].active = !entities[index].active
	if entities[index].active:
		objectives_completed += 1
		update_objectives()

func _on_generic_clicked(index: int) -> void:
	if not entities[index].active:
		entities[index].active = true
		objectives_completed += 1
		update_score(current_score + 10)
		update_objectives()

func update_objectives() -> void:
	var info_label = game_layer.get_node("InfoLabel")
	if info_label:
		info_label.text = "목표: %d/%d 완성" % [objectives_completed, total_objectives]
	
	if objectives_completed >= total_objectives:
		update_score(current_score + 50)
		end_game(true)

extends MinigameBase

var dots: Array[ColorRect] = []
var lines: Array[Line2D] = []
var connections: Array[Vector2i] = []
var target_connections: Array[Vector2i] = []
var current_dot: int = -1

func _ready() -> void:
	game_name = "연결 게임"
	game_description = "점들을 올바르게 연결하세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	create_dots()
	generate_target_connections()

func create_dots() -> void:
	var dot_count = 4 + difficulty
	for i in range(dot_count):
		var dot = ColorRect.new()
		dot.size = Vector2(20, 20)
		dot.position = Vector2(
			100 + (i % 3) * 150,
			150 + (i / 3) * 100
		)
		dot.color = Color.YELLOW
		
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 15
		collision.shape = circle_shape
		area.add_child(collision)
		area.position = dot.position + dot.size / 2
		area.input_event.connect(_on_dot_clicked.bind(i))
		
		dots.append(dot)
		game_layer.add_child(dot)
		game_layer.add_child(area)

func generate_target_connections() -> void:
	target_connections = [Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3)]

func _on_dot_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, dot_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_game_active:
			return
		
		if current_dot == -1:
			current_dot = dot_index
			dots[dot_index].color = Color.RED
		else:
			if current_dot != dot_index:
				create_connection(current_dot, dot_index)
			dots[current_dot].color = Color.YELLOW
			current_dot = -1

func create_connection(dot1: int, dot2: int) -> void:
	var line = Line2D.new()
	line.add_point(dots[dot1].position + dots[dot1].size / 2)
	line.add_point(dots[dot2].position + dots[dot2].size / 2)
	line.default_color = Color.BLUE
	line.width = 3.0
	
	connections.append(Vector2i(min(dot1, dot2), max(dot1, dot2)))
	lines.append(line)
	game_layer.add_child(line)
	
	check_win_condition()

func check_win_condition() -> void:
	if connections.size() >= target_connections.size():
		update_score(current_score + 30)
		end_game(true)

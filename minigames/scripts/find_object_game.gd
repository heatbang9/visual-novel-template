extends MinigameBase

var objects_to_find: Array[ColorRect] = []
var target_objects: Array[String] = ["빨간 상자", "파란 원", "노란 삼각형"]
var objects_found: int = 0
var total_objects: int = 5

func _ready() -> void:
	game_name = "물건 찾기"
	game_description = "숨겨진 물건들을 찾으세요!"
	time_limit = 90.0
	super._ready()

func setup_game() -> void:
	total_objects = 3 + difficulty * 2
	create_objects()

func create_objects() -> void:
	var colors = [Color.RED, Color.BLUE, Color.YELLOW, Color.GREEN, Color.PURPLE]
	var screen_size = get_viewport().size
	
	for i in range(total_objects):
		var obj = ColorRect.new()
		obj.size = Vector2(30, 30)
		obj.position = Vector2(
			randf() * (screen_size.x - 50) + 10,
			randf() * (screen_size.y - 200) + 150
		)
		obj.color = colors[i % colors.size()]
		
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = obj.size
		collision.shape = rect_shape
		area.add_child(collision)
		area.position = obj.position + obj.size / 2
		area.input_event.connect(_on_object_clicked.bind(obj))
		
		objects_to_find.append(obj)
		game_layer.add_child(obj)
		game_layer.add_child(area)

func _on_object_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, obj: ColorRect) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_game_active or obj not in objects_to_find:
			return
		
		objects_found += 1
		update_score(current_score + 10)
		obj.modulate = Color(1, 1, 1, 0.3)
		objects_to_find.erase(obj)
		
		if objects_found >= total_objects:
			end_game(true)
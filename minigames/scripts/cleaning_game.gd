extends MinigameBase

var dirty_spots: Array[ColorRect] = []
var cleaned_spots: int = 0
var total_spots: int = 8

func _ready() -> void:
	game_name = "청소 게임"
	game_description = "더러운 곳을 클릭해서 청소하세요!"
	time_limit = 45.0
	super._ready()

func setup_game() -> void:
	total_spots = 6 + difficulty * 2
	create_dirty_spots()

func create_dirty_spots() -> void:
	var screen_size = get_viewport().size
	for i in range(total_spots):
		var spot = ColorRect.new()
		spot.size = Vector2(40, 40)
		spot.position = Vector2(
			randf() * (screen_size.x - 60) + 10,
			randf() * (screen_size.y - 200) + 150
		)
		spot.color = Color.BROWN
		
		var area = Area2D.new()
		var collision = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = spot.size
		collision.shape = rect_shape
		area.add_child(collision)
		area.position = spot.position + spot.size / 2
		area.input_event.connect(_on_spot_cleaned.bind(spot))
		
		dirty_spots.append(spot)
		game_layer.add_child(spot)
		game_layer.add_child(area)

func _on_spot_cleaned(_viewport: Node, event: InputEvent, _shape_idx: int, spot: ColorRect) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_game_active or spot not in dirty_spots:
			return
		
		cleaned_spots += 1
		update_score(current_score + 5)
		spot.color = Color.WHITE
		dirty_spots.erase(spot)
		
		if cleaned_spots >= total_spots:
			end_game(true)

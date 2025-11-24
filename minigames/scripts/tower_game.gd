extends MinigameBase

var blocks: Array[RigidBody2D] = []
var current_block: RigidBody2D
var tower_height: int = 0
var target_height: int = 5
var spawn_timer: Timer

func _ready() -> void:
	game_name = "탑 쌓기"
	game_description = "블록을 떨어뜨려 높은 탑을 쌓으세요!"
	time_limit = 90.0
	super._ready()

func setup_game() -> void:
	target_height = 4 + difficulty * 2
	create_ground()
	setup_spawn_timer()

func create_ground() -> void:
	var ground = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(400, 20)
	collision.shape = rect_shape
	ground.add_child(collision)
	ground.position = Vector2(get_viewport().size.x / 2, get_viewport().size.y - 50)
	
	var visual = ColorRect.new()
	visual.size = Vector2(400, 20)
	visual.position = Vector2(-200, -10)
	visual.color = Color.BROWN
	ground.add_child(visual)
	game_layer.add_child(ground)

func setup_spawn_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 2.0
	spawn_timer.timeout.connect(spawn_block)
	add_child(spawn_timer)

func on_game_start() -> void:
	spawn_block()
	spawn_timer.start()

func spawn_block() -> void:
	if not is_game_active:
		return
	
	current_block = RigidBody2D.new()
	var collision = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(60, 20)
	collision.shape = rect_shape
	current_block.add_child(collision)
	
	var visual = ColorRect.new()
	visual.size = Vector2(60, 20)
	visual.position = Vector2(-30, -10)
	visual.color = Color.CYAN
	current_block.add_child(visual)
	
	current_block.position = Vector2(randf_range(200, 600), 50)
	current_block.gravity_scale = 0
	current_block.body_entered.connect(_on_block_landed)
	
	blocks.append(current_block)
	game_layer.add_child(current_block)

func _input(event: InputEvent) -> void:
	if not is_game_active or not current_block:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		current_block.gravity_scale = 1
		current_block = null

func _on_block_landed(body: Node) -> void:
	tower_height += 1
	update_score(current_score + 10)
	
	if tower_height >= target_height:
		end_game(true)

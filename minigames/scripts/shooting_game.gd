extends MinigameBase

var targets: Array[Area2D] = []
var crosshair: Sprite2D
var targets_hit: int = 0
var targets_needed: int = 10
var target_spawn_timer: Timer

func _ready() -> void:
	game_name = "슈팅 게임"
	game_description = "타겟을 클릭해서 맞추세요!"
	time_limit = 45.0
	super._ready()

func setup_game() -> void:
	targets_needed = 5 + difficulty * 3
	
	crosshair = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	texture.set_image(image)
	crosshair.texture = texture
	crosshair.visible = false
	game_layer.add_child(crosshair)
	
	target_spawn_timer = Timer.new()
	target_spawn_timer.wait_time = 2.0 - (difficulty * 0.3)
	target_spawn_timer.autostart = false
	target_spawn_timer.timeout.connect(spawn_target)
	add_child(target_spawn_timer)

func on_game_start() -> void:
	target_spawn_timer.start()
	spawn_target()

func spawn_target() -> void:
	if not is_game_active:
		return
	
	var target = Area2D.new()
	var collision = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 30
	collision.shape = circle_shape
	target.add_child(collision)
	
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(60, 60, false, Image.FORMAT_RGBA8)
	image.fill(Color.YELLOW)
	texture.set_image(image)
	sprite.texture = texture
	target.add_child(sprite)
	
	var screen_size = get_viewport().size
	target.position = Vector2(
		randf() * (screen_size.x - 60) + 30,
		randf() * (screen_size.y - 60) + 30
	)
	
	target.input_event.connect(_on_target_clicked.bind(target))
	targets.append(target)
	game_layer.add_child(target)
	
	var tween = create_tween()
	tween.tween_property(target, "modulate", Color.TRANSPARENT, 3.0)
	tween.tween_callback(remove_target.bind(target))

func _on_target_clicked(_viewport: Node, event: InputEvent, _shape_idx: int, target: Area2D) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not is_game_active:
			return
		
		targets_hit += 1
		update_score(current_score + 10)
		remove_target(target)
		
		if targets_hit >= targets_needed:
			end_game(true)

func remove_target(target: Area2D) -> void:
	if target in targets:
		targets.erase(target)
	if is_instance_valid(target):
		target.queue_free()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_game_active:
		crosshair.global_position = event.position
		crosshair.visible = true
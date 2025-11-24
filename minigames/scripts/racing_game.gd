extends MinigameBase

var player_car: ColorRect
var obstacles: Array[ColorRect] = []
var finish_line: ColorRect
var distance_traveled: float = 0.0
var car_speed: float = 200.0
var finish_distance: float = 1000.0
var obstacle_spawn_timer: Timer

func _ready() -> void:
	game_name = "경주 게임"
	game_description = "장애물을 피해 결승선에 도달하세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	finish_distance = 800.0 + difficulty * 200.0
	
	player_car = ColorRect.new()
	player_car.size = Vector2(40, 60)
	player_car.position = Vector2(get_viewport().size.x / 2 - 20, get_viewport().size.y - 100)
	player_car.color = Color.GREEN
	game_layer.add_child(player_car)
	
	finish_line = ColorRect.new()
	finish_line.size = Vector2(get_viewport().size.x, 20)
	finish_line.position = Vector2(0, -finish_distance)
	finish_line.color = Color.YELLOW
	game_layer.add_child(finish_line)
	
	obstacle_spawn_timer = Timer.new()
	obstacle_spawn_timer.wait_time = 1.5 - (difficulty * 0.2)
	obstacle_spawn_timer.timeout.connect(spawn_obstacle)
	add_child(obstacle_spawn_timer)

func on_game_start() -> void:
	obstacle_spawn_timer.start()

func spawn_obstacle() -> void:
	if not is_game_active:
		return
	
	var obstacle = ColorRect.new()
	obstacle.size = Vector2(40, 40)
	obstacle.position = Vector2(
		randf() * (get_viewport().size.x - 40),
		-50
	)
	obstacle.color = Color.RED
	
	obstacles.append(obstacle)
	game_layer.add_child(obstacle)

func _process(delta: float) -> void:
	super._process(delta)
	
	if not is_game_active:
		return
	
	handle_input(delta)
	move_world(delta)
	check_collisions()
	update_progress()

func handle_input(delta: float) -> void:
	var move_speed = 300.0
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		player_car.position.x -= move_speed * delta
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		player_car.position.x += move_speed * delta
	
	player_car.position.x = clamp(player_car.position.x, 0, get_viewport().size.x - player_car.size.x)

func move_world(delta: float) -> void:
	distance_traveled += car_speed * delta
	
	finish_line.position.y = -finish_distance + distance_traveled
	
	for obstacle in obstacles.duplicate():
		obstacle.position.y += car_speed * delta
		if obstacle.position.y > get_viewport().size.y:
			obstacles.erase(obstacle)
			obstacle.queue_free()

func check_collisions() -> void:
	var player_rect = Rect2(player_car.position, player_car.size)
	
	for obstacle in obstacles:
		var obstacle_rect = Rect2(obstacle.position, obstacle.size)
		if player_rect.intersects(obstacle_rect):
			end_game(false)
			return
	
	if distance_traveled >= finish_distance:
		update_score(current_score + 100)
		end_game(true)

func update_progress() -> void:
	var progress = distance_traveled / finish_distance
	update_score(int(progress * 50))
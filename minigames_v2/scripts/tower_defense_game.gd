extends MinigameBase

var towers: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var wave_number: int = 1
var max_waves: int = 5
var enemy_spawn_timer: Timer
var wave_enemies_spawned: int = 0
var enemies_per_wave: int = 5

func _ready() -> void:
	game_name_key = "tower_defense_name"
	game_desc_key = "tower_defense_desc"
	time_limit = 180.0
	super._ready()

func setup_game() -> void:
	max_waves = 3 + difficulty
	enemies_per_wave = 4 + difficulty * 2
	setup_spawn_timer()
	create_path()
	
var path_points: Array[Vector2] = []

func create_path() -> void:
	path_points = [
		Vector2(0, 250),
		Vector2(200, 250),
		Vector2(200, 150),
		Vector2(400, 150),
		Vector2(400, 350),
		Vector2(600, 350)
	]
	
	for i in range(path_points.size() - 1):
		var line = Line2D.new()
		line.add_point(path_points[i])
		line.add_point(path_points[i + 1])
		line.default_color = Color.BROWN
		line.width = 20
		game_layer.add_child(line)

func setup_spawn_timer() -> void:
	enemy_spawn_timer = Timer.new()
	enemy_spawn_timer.wait_time = 2.0 - (difficulty * 0.2)
	enemy_spawn_timer.timeout.connect(spawn_enemy)
	add_child(enemy_spawn_timer)

func on_game_start() -> void:
	start_wave()

func start_wave() -> void:
	wave_enemies_spawned = 0
	enemy_spawn_timer.start()
	
	var wave_label = Label.new()
	wave_label.text = "Wave %d/%d" % [wave_number, max_waves]
	wave_label.position = Vector2(50, 100)
	wave_label.size = Vector2(200, 30)
	game_layer.add_child(wave_label)

func spawn_enemy() -> void:
	if not is_game_active:
		return
	
	if wave_enemies_spawned >= enemies_per_wave:
		enemy_spawn_timer.stop()
		return
	
	var enemy = {
		"health": 30 + wave_number * 10,
		"max_health": 30 + wave_number * 10,
		"speed": 50 + get_random_int(-10, 20),
		"path_progress": 0.0,
		"position": path_points[0],
		"sprite": null
	}
	
	var sprite = ColorRect.new()
	sprite.size = Vector2(15, 15)
	sprite.color = Color.RED
	sprite.position = enemy.position
	enemy.sprite = sprite
	game_layer.add_child(sprite)
	
	enemies.append(enemy)
	wave_enemies_spawned += 1

func _process(delta: float) -> void:
	super._process(delta)
	if not is_game_active:
		return
	
	update_enemies(delta)
	update_towers(delta)
	
	if enemies.is_empty() and wave_enemies_spawned >= enemies_per_wave:
		if wave_number >= max_waves:
			end_game(true)
		else:
			wave_number += 1
			start_wave()

func update_enemies(delta: float) -> void:
	for enemy in enemies.duplicate():
		enemy.path_progress += enemy.speed * delta
		
		var new_pos = get_position_on_path(enemy.path_progress)
		if new_pos == Vector2.ZERO:
			enemies.erase(enemy)
			if enemy.sprite:
				enemy.sprite.queue_free()
			continue
		
		enemy.position = new_pos
		if enemy.sprite:
			enemy.sprite.position = new_pos

func get_position_on_path(progress: float) -> Vector2:
	if progress >= 500:
		return Vector2.ZERO
	
	var segment_length = 100
	var segment = int(progress / segment_length)
	var t = (progress % segment_length) / segment_length
	
	if segment >= path_points.size() - 1:
		return Vector2.ZERO
	
	return path_points[segment].lerp(path_points[segment + 1], t)

func update_towers(delta: float) -> void:
	for tower in towers:
		tower.cooldown -= delta
		if tower.cooldown <= 0:
			var target = find_nearest_enemy(tower.position)
			if target and tower.position.distance_to(target.position) <= tower.range:
				shoot_at_enemy(tower, target)
				tower.cooldown = tower.fire_rate

func find_nearest_enemy(tower_pos: Vector2) -> Dictionary:
	var nearest = {}
	var min_distance = INF
	
	for enemy in enemies:
		var distance = tower_pos.distance_to(enemy.position)
		if distance < min_distance:
			min_distance = distance
			nearest = enemy
	
	return nearest if min_distance != INF else {}

func shoot_at_enemy(tower: Dictionary, enemy: Dictionary) -> void:
	enemy.health -= tower.damage
	if enemy.health <= 0:
		enemies.erase(enemy)
		if enemy.sprite:
			enemy.sprite.queue_free()
		update_score(current_score + 5)

func _input(event: InputEvent) -> void:
	if not is_game_active:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		place_tower(event.position)
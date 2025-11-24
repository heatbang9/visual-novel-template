extends MinigameBase

var plant: ColorRect
var growth_level: int = 0
var max_growth: int = 5
var water_button: Button
var water_timer: Timer
var last_water_time: float = 0

func _ready() -> void:
	game_name = "식물 키우기"
	game_description = "적절히 물을 줘서 식물을 키우세요!"
	time_limit = 120.0
	super._ready()

func setup_game() -> void:
	max_growth = 4 + difficulty
	create_plant()
	create_water_button()
	setup_timer()

func create_plant() -> void:
	plant = ColorRect.new()
	plant.size = Vector2(50, 50)
	plant.position = Vector2(get_viewport().size.x / 2 - 25, 250)
	plant.color = Color.GREEN
	game_layer.add_child(plant)

func create_water_button() -> void:
	water_button = Button.new()
	water_button.text = "물주기"
	water_button.size = Vector2(100, 50)
	water_button.position = Vector2(get_viewport().size.x / 2 - 50, 350)
	water_button.pressed.connect(_on_water_pressed)
	game_layer.add_child(water_button)

func setup_timer() -> void:
	water_timer = Timer.new()
	water_timer.wait_time = 1.0
	water_timer.timeout.connect(_on_water_timer_timeout)
	add_child(water_timer)

func _on_water_pressed() -> void:
	if not is_game_active:
		return
	
	var current_time = Time.get_time_dict_from_system()["unix"]
	if current_time - last_water_time > 5:
		growth_level += 1
		last_water_time = current_time
		update_plant_size()
		update_score(current_score + 10)
		
		if growth_level >= max_growth:
			end_game(true)
	else:
		growth_level = max(0, growth_level - 1)
		update_plant_size()

func update_plant_size() -> void:
	var new_size = 50 + growth_level * 20
	plant.size = Vector2(new_size, new_size)
	plant.position = Vector2(get_viewport().size.x / 2 - new_size / 2, 250 - growth_level * 10)

func _on_water_timer_timeout() -> void:
	if is_game_active:
		water_timer.start()

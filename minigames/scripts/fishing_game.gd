extends MinigameBase

var fishing_line: Line2D
var bobber: ColorRect
var fish_zone: ColorRect
var is_fish_hooked: bool = false
var fish_timer: Timer
var hook_progress: float = 0.0
var progress_bar: ProgressBar
var fish_caught: int = 0
var fish_needed: int = 3

func _ready() -> void:
	game_name = "낚시 게임"
	game_description = "물고기가 물었을 때 스페이스바를 누르세요!"
	time_limit = 90.0
	super._ready()

func setup_game() -> void:
	fish_needed = 2 + difficulty
	
	var water_area = ColorRect.new()
	water_area.size = Vector2(400, 200)
	water_area.position = Vector2(get_viewport().size.x / 2 - 200, 200)
	water_area.color = Color.BLUE
	game_layer.add_child(water_area)
	
	fishing_line = Line2D.new()
	fishing_line.add_point(Vector2(get_viewport().size.x / 2, 150))
	fishing_line.add_point(Vector2(get_viewport().size.x / 2, 250))
	fishing_line.default_color = Color.BROWN
	fishing_line.width = 3.0
	game_layer.add_child(fishing_line)
	
	bobber = ColorRect.new()
	bobber.size = Vector2(20, 20)
	bobber.position = Vector2(get_viewport().size.x / 2 - 10, 240)
	bobber.color = Color.RED
	game_layer.add_child(bobber)
	
	fish_zone = ColorRect.new()
	fish_zone.size = Vector2(60, 60)
	fish_zone.color = Color.YELLOW
	fish_zone.visible = false
	game_layer.add_child(fish_zone)
	
	progress_bar = ProgressBar.new()
	progress_bar.size = Vector2(200, 30)
	progress_bar.position = Vector2(get_viewport().size.x / 2 - 100, 450)
	progress_bar.max_value = 100
	progress_bar.value = 0
	game_layer.add_child(progress_bar)
	
	fish_timer = Timer.new()
	fish_timer.wait_time = randf_range(2.0, 5.0)
	fish_timer.one_shot = true
	fish_timer.timeout.connect(fish_bite)
	add_child(fish_timer)

func on_game_start() -> void:
	start_fishing()

func start_fishing() -> void:
	is_fish_hooked = false
	hook_progress = 0.0
	fish_zone.visible = false
	fish_timer.wait_time = randf_range(3.0 - difficulty * 0.5, 6.0 - difficulty * 0.5)
	fish_timer.start()

func fish_bite() -> void:
	is_fish_hooked = true
	fish_zone.position = Vector2(
		get_viewport().size.x / 2 - 30 + randf_range(-50, 50),
		250 + randf_range(-20, 20)
	)
	fish_zone.visible = true
	
	var bite_timer = Timer.new()
	bite_timer.wait_time = 2.0 + difficulty
	bite_timer.one_shot = true
	bite_timer.timeout.connect(fish_escape)
	add_child(bite_timer)
	bite_timer.start()

func fish_escape() -> void:
	is_fish_hooked = false
	fish_zone.visible = false
	hook_progress = 0.0
	progress_bar.value = 0
	start_fishing()

func _input(event: InputEvent) -> void:
	if not is_game_active:
		return
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if is_fish_hooked:
			hook_progress += 20.0
			progress_bar.value = hook_progress
			
			if hook_progress >= 100.0:
				catch_fish()

func catch_fish() -> void:
	fish_caught += 1
	update_score(current_score + 15)
	is_fish_hooked = false
	fish_zone.visible = false
	hook_progress = 0.0
	progress_bar.value = 0
	
	if fish_caught >= fish_needed:
		end_game(true)
	else:
		await get_tree().create_timer(1.0).timeout
		start_fishing()
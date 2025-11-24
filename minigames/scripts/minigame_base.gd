extends Control
class_name MinigameBase

signal game_completed(success: bool, score: int)
signal game_exited

@export var game_name_key: String = ""
@export var game_desc_key: String = ""
@export var time_limit: float = 60.0
@export var difficulty: int = 1

var game_timer: Timer
var is_game_active: bool = false
var current_score: int = 0
var localization_manager: LocalizationManager
var random_seed: int

@onready var ui_layer = $UILayer
@onready var game_layer = $GameLayer

func _ready() -> void:
	localization_manager = LocalizationManager.new()
	add_child(localization_manager)
	localization_manager.language_changed.connect(_on_language_changed)
	
	random_seed = randi()
	seed(random_seed)
	
	setup_ui()
	setup_game_timer()
	setup_game()

func setup_ui() -> void:
	var back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = localization_manager.get_text("back_button", "뒤로 가기")
	back_button.position = Vector2(10, 10)
	back_button.size = Vector2(100, 40)
	back_button.pressed.connect(_on_back_pressed)
	ui_layer.add_child(back_button)
	
	var timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.position = Vector2(get_viewport().size.x - 150, 10)
	timer_label.size = Vector2(140, 40)
	timer_label.text = "%s: %.1f" % [localization_manager.get_text("time", "시간"), time_limit]
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_layer.add_child(timer_label)
	
	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(get_viewport().size.x - 150, 60)
	score_label.size = Vector2(140, 40)
	score_label.text = "%s: 0" % localization_manager.get_text("score", "점수")
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_layer.add_child(score_label)

func setup_game_timer() -> void:
	game_timer = Timer.new()
	game_timer.wait_time = time_limit
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_game_timeout)
	add_child(game_timer)

func setup_game() -> void:
	pass

func start_game() -> void:
	is_game_active = true
	game_timer.start()
	on_game_start()

func end_game(success: bool) -> void:
	if not is_game_active:
		return
	
	is_game_active = false
	game_timer.stop()
	on_game_end(success)
	game_completed.emit(success, current_score)

func on_game_start() -> void:
	pass

func on_game_end(success: bool) -> void:
	pass

func update_score(new_score: int) -> void:
	current_score = new_score
	var score_label = ui_layer.get_node("ScoreLabel")
	if score_label:
		score_label.text = "%s: %d" % [localization_manager.get_text("score", "점수"), current_score]

func _process(_delta: float) -> void:
	if is_game_active and game_timer:
		var timer_label = ui_layer.get_node("TimerLabel")
		if timer_label:
			timer_label.text = "%s: %.1f" % [localization_manager.get_text("time", "시간"), game_timer.time_left]

func _on_language_changed(_new_language: String) -> void:
	update_ui_text()

func update_ui_text() -> void:
	var back_button = ui_layer.get_node("BackButton")
	if back_button:
		back_button.text = localization_manager.get_text("back_button", "뒤로 가기")
	
	var timer_label = ui_layer.get_node("TimerLabel")
	if timer_label and game_timer:
		timer_label.text = "%s: %.1f" % [localization_manager.get_text("time", "시간"), game_timer.time_left]
	
	var score_label = ui_layer.get_node("ScoreLabel")
	if score_label:
		score_label.text = "%s: %d" % [localization_manager.get_text("score", "점수"), current_score]

func get_random_int(min_val: int, max_val: int) -> int:
	return randi_range(min_val, max_val)

func get_random_float(min_val: float, max_val: float) -> float:
	return randf_range(min_val, max_val)

func get_random_choice(choices: Array) -> Variant:
	return choices[randi() % choices.size()]

func _on_game_timeout() -> void:
	end_game(false)

func _on_back_pressed() -> void:
	end_game(false)
	game_exited.emit()
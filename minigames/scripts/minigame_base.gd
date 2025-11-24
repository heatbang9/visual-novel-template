extends Control
class_name MinigameBase

signal game_completed(success: bool, score: int)
signal game_exited

@export var game_name: String = ""
@export var game_description: String = ""
@export var time_limit: float = 60.0
@export var difficulty: int = 1

var game_timer: Timer
var is_game_active: bool = false
var current_score: int = 0

@onready var ui_layer = $UILayer
@onready var game_layer = $GameLayer

func _ready() -> void:
	setup_ui()
	setup_game_timer()
	setup_game()

func setup_ui() -> void:
	var back_button = Button.new()
	back_button.text = "뒤로 가기"
	back_button.position = Vector2(10, 10)
	back_button.size = Vector2(100, 40)
	back_button.pressed.connect(_on_back_pressed)
	ui_layer.add_child(back_button)
	
	var timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.position = Vector2(get_viewport().size.x - 150, 10)
	timer_label.size = Vector2(140, 40)
	timer_label.text = "시간: %.1f" % time_limit
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ui_layer.add_child(timer_label)
	
	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.position = Vector2(get_viewport().size.x - 150, 60)
	score_label.size = Vector2(140, 40)
	score_label.text = "점수: 0"
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
		score_label.text = "점수: %d" % current_score

func _process(_delta: float) -> void:
	if is_game_active and game_timer:
		var timer_label = ui_layer.get_node("TimerLabel")
		if timer_label:
			timer_label.text = "시간: %.1f" % game_timer.time_left

func _on_game_timeout() -> void:
	end_game(false)

func _on_back_pressed() -> void:
	end_game(false)
	game_exited.emit()
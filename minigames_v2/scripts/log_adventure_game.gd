extends MinigameBase

var current_scenario: Dictionary
var choices_made: int = 0
var scenarios: Array[Dictionary] = []

func _ready() -> void:
	game_name_key = "log_adventure_name"
	game_desc_key = "log_adventure_desc"
	time_limit = 120.0
	super._ready()

func setup_game() -> void:
	create_scenarios()
	start_scenario()

func create_scenarios() -> void:
	scenarios = [
		{
			"text": "당신은 어두운 숲에서 길을 잃었습니다.",
			"choices": [
				{"text": "왼쪽 길로 간다", "result": "treasure"},
				{"text": "오른쪽 길로 간다", "result": "enemy"},
				{"text": "제자리에서 기다린다", "result": "safe"}
			]
		},
		{
			"text": "신비한 상자를 발견했습니다.",
			"choices": [
				{"text": "상자를 연다", "result": get_random_choice(["treasure", "trap"])},
				{"text": "상자를 무시한다", "result": "safe"},
				{"text": "조심히 살펴본다", "result": "clue"}
			]
		}
	]

func start_scenario() -> void:
	current_scenario = get_random_choice(scenarios)
	show_scenario()

func show_scenario() -> void:
	clear_ui()
	
	var text_label = Label.new()
	text_label.text = current_scenario.text
	text_label.position = Vector2(50, 150)
	text_label.size = Vector2(500, 100)
	text_label.autowrap_mode = true
	game_layer.add_child(text_label)
	
	for i in range(current_scenario.choices.size()):
		var choice = current_scenario.choices[i]
		var button = Button.new()
		button.text = choice.text
		button.position = Vector2(50, 250 + i * 60)
		button.size = Vector2(400, 50)
		button.pressed.connect(_on_choice_selected.bind(choice))
		game_layer.add_child(button)

func _on_choice_selected(choice: Dictionary) -> void:
	if not is_game_active:
		return
	
	choices_made += 1
	var result = choice.result
	
	match result:
		"treasure":
			update_score(current_score + 30)
		"enemy":
			if get_random_int(0, 100) < 50:
				end_game(false)
				return
		"safe":
			update_score(current_score + 10)
		"trap":
			update_score(current_score - 10)
	
	if choices_made >= 3 + difficulty:
		end_game(true)
	else:
		await get_tree().create_timer(1.0).timeout
		start_scenario()

func clear_ui() -> void:
	for child in game_layer.get_children():
		child.queue_free()

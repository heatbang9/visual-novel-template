extends MinigameBase

var current_question: Dictionary
var answer_buttons: Array[Button] = []
var question_label: Label
var questions_solved: int = 0
var questions_needed: int = 5

func _ready() -> void:
	game_name = "숫자 맞추기"
	game_description = "수학 문제를 풀어보세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	questions_needed = 3 + difficulty * 2
	
	question_label = Label.new()
	question_label.size = Vector2(400, 100)
	question_label.position = Vector2(get_viewport().size.x / 2 - 200, 100)
	question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	question_label.add_theme_font_size_override("font_size", 24)
	game_layer.add_child(question_label)
	
	for i in range(4):
		var button = Button.new()
		button.size = Vector2(100, 50)
		button.position = Vector2(100 + i * 120, 250)
		button.pressed.connect(_on_answer_selected.bind(i))
		answer_buttons.append(button)
		game_layer.add_child(button)

func on_game_start() -> void:
	generate_new_question()

func generate_new_question() -> void:
	var num1 = randi() % (10 * difficulty) + 1
	var num2 = randi() % (10 * difficulty) + 1
	var operation = ["+", "-", "*"][randi() % 3]
	
	var correct_answer: int
	var question_text: String
	
	match operation:
		"+":
			correct_answer = num1 + num2
			question_text = "%d + %d = ?" % [num1, num2]
		"-":
			if num1 < num2:
				var temp = num1
				num1 = num2
				num2 = temp
			correct_answer = num1 - num2
			question_text = "%d - %d = ?" % [num1, num2]
		"*":
			num1 = randi() % 10 + 1
			num2 = randi() % 10 + 1
			correct_answer = num1 * num2
			question_text = "%d × %d = ?" % [num1, num2]
	
	current_question = {
		"text": question_text,
		"correct_answer": correct_answer,
		"correct_index": randi() % 4
	}
	
	question_label.text = question_text
	
	var answers: Array[int] = []
	answers.resize(4)
	answers[current_question.correct_index] = correct_answer
	
	for i in range(4):
		if i != current_question.correct_index:
			var wrong_answer = correct_answer + (randi() % 20 - 10)
			while wrong_answer == correct_answer or wrong_answer in answers:
				wrong_answer = correct_answer + (randi() % 20 - 10)
			answers[i] = wrong_answer
	
	for i in range(4):
		answer_buttons[i].text = str(answers[i])

func _on_answer_selected(button_index: int) -> void:
	if not is_game_active:
		return
	
	if button_index == current_question.correct_index:
		questions_solved += 1
		update_score(current_score + 10)
		
		if questions_solved >= questions_needed:
			end_game(true)
		else:
			await get_tree().create_timer(0.5).timeout
			generate_new_question()
	else:
		end_game(false)
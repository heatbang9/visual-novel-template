extends MinigameBase

var word_list: Array[String] = ["사과", "바나나", "포도", "딸기", "수박", "멜론", "오렌지", "복숭아", "키위", "체리"]
var current_word: String = ""
var hint_label: Label
var guess_input: LineEdit
var submit_button: Button
var attempts: int = 0
var max_attempts: int = 3

func _ready() -> void:
	game_name = "단어 맞히기"
	game_description = "힌트를 보고 단어를 맞춰보세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	max_attempts = 5 - difficulty
	
	hint_label = Label.new()
	hint_label.size = Vector2(400, 100)
	hint_label.position = Vector2(get_viewport().size.x / 2 - 200, 150)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.autowrap_mode = true
	game_layer.add_child(hint_label)
	
	guess_input = LineEdit.new()
	guess_input.size = Vector2(200, 40)
	guess_input.position = Vector2(get_viewport().size.x / 2 - 100, 300)
	guess_input.placeholder_text = "단어를 입력하세요"
	game_layer.add_child(guess_input)
	
	submit_button = Button.new()
	submit_button.text = "제출"
	submit_button.size = Vector2(100, 40)
	submit_button.position = Vector2(get_viewport().size.x / 2 - 50, 350)
	submit_button.pressed.connect(_on_submit_pressed)
	game_layer.add_child(submit_button)

func on_game_start() -> void:
	generate_new_word()

func generate_new_word() -> void:
	current_word = word_list[randi() % word_list.size()]
	var hints = {
		"사과": "빨간색 과일, 아담과 이브",
		"바나나": "노란색 과일, 원숭이가 좋아함",
		"포도": "포도주의 재료, 송이송이",
		"딸기": "빨간 작은 과일, 우유와 잘 어울림",
		"수박": "여름 과일, 초록색 겉껍질",
		"멜론": "달콤한 과일, 망 모양",
		"오렌지": "비타민C가 풍부한 과일",
		"복숭아": "털이 있는 과일, 핑크색",
		"키위": "갈색 털 과일, 초록색 속",
		"체리": "작고 빨간 과일, 버찌"
	}
	hint_label.text = "힌트: " + hints.get(current_word, "과일입니다!")
	attempts = 0
	guess_input.text = ""

func _on_submit_pressed() -> void:
	if not is_game_active:
		return
	
	var guess = guess_input.text.strip_edges()
	attempts += 1
	
	if guess == current_word:
		update_score(current_score + 20)
		end_game(true)
	elif attempts >= max_attempts:
		end_game(false)
	else:
		guess_input.text = ""
		hint_label.text += "\n시도 %d/%d" % [attempts, max_attempts]
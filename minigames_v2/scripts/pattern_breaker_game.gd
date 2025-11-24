extends MinigameBase

var cipher_text: String = ""
var decoded_text: String = ""
var alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var cipher_key: Dictionary = {}
var input_field: LineEdit
var target_word: String = ""

func _ready() -> void:
	game_name_key = "pattern_breaker_name"
	game_desc_key = "pattern_breaker_desc"
	time_limit = 90.0
	super._ready()

func setup_game() -> void:
	create_cipher()
	create_ui()

func create_cipher() -> void:
	var words = ["HELLO", "WORLD", "GODOT", "GAME", "CODE"]
	target_word = get_random_choice(words)
	
	var shuffled_alphabet = alphabet.split("")
	shuffled_alphabet.shuffle()
	
	for i in range(alphabet.length()):
		cipher_key[alphabet[i]] = shuffled_alphabet[i]
	
	cipher_text = ""
	for char in target_word:
		cipher_text += cipher_key[char]

func create_ui() -> void:
	var cipher_label = Label.new()
	cipher_label.text = "암호: " + cipher_text
	cipher_label.position = Vector2(50, 150)
	cipher_label.size = Vector2(400, 30)
	game_layer.add_child(cipher_label)
	
	input_field = LineEdit.new()
	input_field.position = Vector2(50, 200)
	input_field.size = Vector2(200, 30)
	input_field.placeholder_text = "답 입력"
	game_layer.add_child(input_field)
	
	var submit_button = Button.new()
	submit_button.text = "제출"
	submit_button.position = Vector2(260, 200)
	submit_button.size = Vector2(80, 30)
	submit_button.pressed.connect(_on_submit)
	game_layer.add_child(submit_button)

func _on_submit() -> void:
	if input_field.text.to_upper() == target_word:
		update_score(current_score + 50)
		end_game(true)
	else:
		end_game(false)

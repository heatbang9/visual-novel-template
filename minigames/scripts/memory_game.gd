extends MinigameBase

var card_grid: Array[Button] = []
var card_values: Array[int] = []
var revealed_cards: Array[int] = []
var matched_pairs: int = 0
var grid_size: int = 4
var total_pairs: int = 8
var can_click: bool = true

func _ready() -> void:
	game_name = "기억력 테스트"
	game_description = "같은 그림의 카드 쌍을 찾으세요!"
	time_limit = 90.0
	super._ready()

func setup_game() -> void:
	grid_size = 4
	total_pairs = (grid_size * grid_size) / 2
	
	if difficulty > 2:
		grid_size = 6
		total_pairs = (grid_size * grid_size) / 2
	
	create_card_values()
	create_card_grid()

func create_card_values() -> void:
	card_values.clear()
	
	for i in range(total_pairs):
		card_values.append(i)
		card_values.append(i)
	
	card_values.shuffle()

func create_card_grid() -> void:
	var button_size = 60
	var spacing = 10
	var start_x = (get_viewport().size.x - (grid_size * (button_size + spacing) - spacing)) / 2
	var start_y = 100
	
	for i in range(grid_size * grid_size):
		var button = Button.new()
		button.size = Vector2(button_size, button_size)
		button.text = "?"
		
		var row = i / grid_size
		var col = i % grid_size
		button.position = Vector2(
			start_x + col * (button_size + spacing),
			start_y + row * (button_size + spacing)
		)
		
		button.pressed.connect(_on_card_clicked.bind(i))
		card_grid.append(button)
		game_layer.add_child(button)

func _on_card_clicked(card_index: int) -> void:
	if not is_game_active or not can_click:
		return
	
	if card_index in revealed_cards or card_grid[card_index].disabled:
		return
	
	reveal_card(card_index)
	revealed_cards.append(card_index)
	
	if revealed_cards.size() == 2:
		can_click = false
		await get_tree().create_timer(1.0).timeout
		check_match()

func reveal_card(card_index: int) -> void:
	var card_value = card_values[card_index]
	var symbols = ["♠", "♥", "♦", "♣", "★", "●", "▲", "■", "♪", "☀", "☽", "❀", "⚡", "🔥", "❄", "🌟"]
	card_grid[card_index].text = symbols[card_value % symbols.size()]

func check_match() -> void:
	var card1_index = revealed_cards[0]
	var card2_index = revealed_cards[1]
	
	if card_values[card1_index] == card_values[card2_index]:
		card_grid[card1_index].disabled = true
		card_grid[card2_index].disabled = true
		matched_pairs += 1
		update_score(current_score + 10)
		
		if matched_pairs >= total_pairs:
			end_game(true)
	else:
		card_grid[card1_index].text = "?"
		card_grid[card2_index].text = "?"
	
	revealed_cards.clear()
	can_click = true
extends MinigameBase

var seesaw_base: ColorRect
var seesaw_beam: ColorRect
var left_weight: int = 0
var right_weight: int = 0
var weight_buttons: Array[Button] = []
var target_balance: int = 0

func _ready() -> void:
	game_name = "균형 맞추기"
	game_description = "시소의 균형을 맞춰보세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	target_balance = 5 + difficulty * 2
	create_seesaw()
	create_weight_buttons()

func create_seesaw() -> void:
	seesaw_base = ColorRect.new()
	seesaw_base.size = Vector2(20, 100)
	seesaw_base.position = Vector2(get_viewport().size.x / 2 - 10, 200)
	seesaw_base.color = Color.BROWN
	game_layer.add_child(seesaw_base)
	
	seesaw_beam = ColorRect.new()
	seesaw_beam.size = Vector2(300, 10)
	seesaw_beam.position = Vector2(get_viewport().size.x / 2 - 150, 245)
	seesaw_beam.color = Color.GRAY
	game_layer.add_child(seesaw_beam)

func create_weight_buttons() -> void:
	var weights = [1, 2, 3, 5]
	for i in range(weights.size()):
		var button = Button.new()
		button.text = str(weights[i]) + "kg"
		button.size = Vector2(80, 40)
		button.position = Vector2(100 + i * 100, 350)
		button.pressed.connect(_on_weight_selected.bind(weights[i]))
		weight_buttons.append(button)
		game_layer.add_child(button)
	
	var left_button = Button.new()
	left_button.text = "왼쪽"
	left_button.size = Vector2(100, 40)
	left_button.position = Vector2(200, 400)
	left_button.pressed.connect(_place_weight.bind(true))
	game_layer.add_child(left_button)
	
	var right_button = Button.new()
	right_button.text = "오른쪽"
	right_button.size = Vector2(100, 40)
	right_button.position = Vector2(350, 400)
	right_button.pressed.connect(_place_weight.bind(false))
	game_layer.add_child(right_button)

var selected_weight: int = 0

func _on_weight_selected(weight: int) -> void:
	selected_weight = weight

func _place_weight(is_left: bool) -> void:
	if not is_game_active or selected_weight == 0:
		return
	
	if is_left:
		left_weight += selected_weight
	else:
		right_weight += selected_weight
	
	update_seesaw()
	check_balance()

func update_seesaw() -> void:
	var balance_diff = right_weight - left_weight
	var rotation = min(max(balance_diff * 5, -30), 30)
	seesaw_beam.rotation_degrees = rotation

func check_balance() -> void:
	if abs(left_weight - right_weight) <= 1 and left_weight >= target_balance:
		update_score(current_score + 50)
		end_game(true)
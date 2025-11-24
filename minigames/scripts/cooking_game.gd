extends MinigameBase

var ingredients: Array[Button] = []
var recipe_sequence: Array[String] = []
var player_sequence: Array[String] = []
var ingredient_names: Array[String] = ["토마토", "양파", "당근", "감자"]

func _ready() -> void:
	game_name = "요리 게임"
	game_description = "레시피 순서대로 재료를 추가하세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	create_ingredients()
	generate_recipe()
	show_recipe()

func create_ingredients() -> void:
	for i in range(ingredient_names.size()):
		var button = Button.new()
		button.text = ingredient_names[i]
		button.size = Vector2(100, 60)
		button.position = Vector2(100 + i * 120, 300)
		button.pressed.connect(_on_ingredient_selected.bind(ingredient_names[i]))
		ingredients.append(button)
		game_layer.add_child(button)

func generate_recipe() -> void:
	recipe_sequence.clear()
	var recipe_length = 3 + difficulty
	for i in range(recipe_length):
		recipe_sequence.append(ingredient_names[randi() % ingredient_names.size()])

func show_recipe() -> void:
	var recipe_label = Label.new()
	recipe_label.text = "레시피: " + " → ".join(recipe_sequence)
	recipe_label.size = Vector2(600, 50)
	recipe_label.position = Vector2(50, 150)
	recipe_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_layer.add_child(recipe_label)

func _on_ingredient_selected(ingredient: String) -> void:
	if not is_game_active:
		return
	
	player_sequence.append(ingredient)
	
	if player_sequence.size() > recipe_sequence.size():
		end_game(false)
		return
	
	var current_index = player_sequence.size() - 1
	if player_sequence[current_index] != recipe_sequence[current_index]:
		end_game(false)
		return
	
	if player_sequence.size() == recipe_sequence.size():
		update_score(current_score + 40)
		end_game(true)

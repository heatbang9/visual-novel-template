extends MinigameBase

var target_button: Button
var reaction_start_time: float
var clicks_needed: int = 5
var current_clicks: int = 0

func _ready() -> void:
	game_name = "반사신경 게임"
	game_description = "버튼이 나타나면 빠르게 클릭하세요!"
	time_limit = 30.0
	super._ready()

func setup_game() -> void:
	target_button = Button.new()
	target_button.text = "클릭!"
	target_button.size = Vector2(100, 100)
	target_button.visible = false
	target_button.pressed.connect(_on_target_clicked)
	game_layer.add_child(target_button)
	
	clicks_needed = 3 + difficulty * 2

func on_game_start() -> void:
	show_target()

func show_target() -> void:
	var screen_size = get_viewport().size
	target_button.position = Vector2(
		randf() * (screen_size.x - target_button.size.x),
		randf() * (screen_size.y - target_button.size.y)
	)
	target_button.visible = true
	reaction_start_time = Time.get_time_dict_from_system()["unix"]

func _on_target_clicked() -> void:
	if not is_game_active:
		return
	
	current_clicks += 1
	var reaction_time = Time.get_time_dict_from_system()["unix"] - reaction_start_time
	var points = max(1, int(10 - reaction_time * 2))
	update_score(current_score + points)
	
	target_button.visible = false
	
	if current_clicks >= clicks_needed:
		end_game(true)
	else:
		await get_tree().create_timer(1.0).timeout
		if is_game_active:
			show_target()
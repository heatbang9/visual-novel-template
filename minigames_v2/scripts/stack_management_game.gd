extends MinigameBase

var resources: Dictionary = {"wood": 10, "stone": 5, "food": 8}
var target_resources: Dictionary
var day: int = 1
var max_days: int = 7
var day_timer: Timer

func _ready() -> void:
	game_name_key = "stack_management_name"
	game_desc_key = "stack_management_desc"
	time_limit = 150.0
	super._ready()

func setup_game() -> void:
	max_days = 5 + difficulty
	target_resources = {
		"wood": 25 + difficulty * 10,
		"stone": 20 + difficulty * 8,
		"food": 15 + difficulty * 5
	}
	setup_day_timer()
	create_ui()

func setup_day_timer() -> void:
	day_timer = Timer.new()
	day_timer.wait_time = 8.0 - difficulty
	day_timer.timeout.connect(next_day)
	add_child(day_timer)

func on_game_start() -> void:
	day_timer.start()

func create_ui() -> void:
	for i, resource in enumerate(resources.keys()):
		var label = Label.new()
		label.name = resource.capitalize() + "Label"
		label.text = "%s: %d" % [resource.capitalize(), resources[resource]]
		label.position = Vector2(50, 150 + i * 30)
		label.size = Vector2(150, 25)
		game_layer.add_child(label)
		
		var button = Button.new()
		button.text = "Gather " + resource.capitalize()
		button.position = Vector2(220, 150 + i * 30)
		button.size = Vector2(150, 25)
		button.pressed.connect(_on_gather.bind(resource))
		game_layer.add_child(button)

func _on_gather(resource: String) -> void:
	if not is_game_active:
		return
	
	var amount = get_random_int(1, 3)
	resources[resource] += amount
	update_resource_display()

func update_resource_display() -> void:
	for resource in resources.keys():
		var label = game_layer.get_node(resource.capitalize() + "Label")
		if label:
			label.text = "%s: %d" % [resource.capitalize(), resources[resource]]

func next_day() -> void:
	if not is_game_active:
		return
	
	day += 1
	consume_resources()
	
	if day > max_days:
		check_win_condition()
	else:
		day_timer.start()

func consume_resources() -> void:
	resources.food -= get_random_int(2, 4)
	if resources.food < 0:
		end_game(false)

func check_win_condition() -> void:
	var success = true
	for resource in target_resources.keys():
		if resources[resource] < target_resources[resource]:
			success = false
			break
	
	if success:
		update_score(current_score + 100)
	end_game(success)

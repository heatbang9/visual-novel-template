extends MinigameBase

var notes: Array[Control] = []
var hit_line: Line2D
var current_beat: int = 0
var notes_hit: int = 0
var notes_needed: int = 15
var beat_timer: Timer
var beat_interval: float = 1.0

func _ready() -> void:
	game_name = "리듬 게임"
	game_description = "박자에 맞춰 스페이스바를 누르세요!"
	time_limit = 60.0
	super._ready()

func setup_game() -> void:
	notes_needed = 10 + difficulty * 5
	beat_interval = 1.0 - (difficulty * 0.1)
	
	hit_line = Line2D.new()
	hit_line.add_point(Vector2(0, get_viewport().size.y - 100))
	hit_line.add_point(Vector2(get_viewport().size.x, get_viewport().size.y - 100))
	hit_line.default_color = Color.RED
	hit_line.width = 5.0
	game_layer.add_child(hit_line)
	
	beat_timer = Timer.new()
	beat_timer.wait_time = beat_interval
	beat_timer.autostart = false
	beat_timer.timeout.connect(spawn_note)
	add_child(beat_timer)

func on_game_start() -> void:
	beat_timer.start()

func spawn_note() -> void:
	if not is_game_active:
		return
	
	var note = ColorRect.new()
	note.size = Vector2(40, 40)
	note.position = Vector2(get_viewport().size.x / 2 - 20, 50)
	note.color = Color.CYAN
	
	var note_data = {
		"node": note,
		"target_y": get_viewport().size.y - 100,
		"hit": false
	}
	
	notes.append(note)
	game_layer.add_child(note)
	
	var tween = create_tween()
	tween.tween_property(note, "position:y", get_viewport().size.y, 3.0)
	tween.tween_callback(remove_note.bind(note))

func _input(event: InputEvent) -> void:
	if not is_game_active:
		return
		
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		check_hit()

func check_hit() -> void:
	var hit_zone = 50
	var target_y = get_viewport().size.y - 100
	
	for note in notes:
		if is_instance_valid(note):
			var distance = abs(note.position.y - target_y)
			if distance < hit_zone:
				notes_hit += 1
				var score_bonus = max(1, int(10 - distance / 5))
				update_score(current_score + score_bonus)
				remove_note(note)
				
				if notes_hit >= notes_needed:
					end_game(true)
				return

func remove_note(note: Control) -> void:
	if note in notes:
		notes.erase(note)
	if is_instance_valid(note):
		note.queue_free()
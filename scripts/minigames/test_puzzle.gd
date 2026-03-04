## 테스트 퍼즐 미니게임
## 미니게임 시스템 테스트용
extends MinigameBase
class_name TestPuzzle

## 퍼즐 그리드 크기
var grid_size: int = 3

## 퍼즐 그리드
var puzzle_grid: Array = []

## 버튼 그리드
var button_grid: Array = []

## 빈 칸 위치
var empty_pos: Vector2i = Vector2i.ZERO

## 이동 횟수
var move_count: int = 0


func _ready() -> void:
	super._ready()
	game_name_key = "test_puzzle_name"
	game_desc_key = "test_puzzle_desc"
	time_limit = 120.0


func setup_game() -> void:
	# 난이도에 따른 그리드 크기 조정
	grid_size = 2 + difficulty  # 난이도 1: 3x3, 2: 4x4, ...
	
	# 퍼즐 초기화
	initialize_puzzle()
	
	# UI 생성
	create_puzzle_ui()


## 퍼즐 초기화
func initialize_puzzle() -> void:
	puzzle_grid.clear()
	
	# 숫자 채우기 (1부터 n*n-1까지)
	var numbers: Array = []
	for i in range(1, grid_size * grid_size):
		numbers.append(i)
	numbers.append(0)  # 빈 칸
	
	# 셔플 (해결 가능한 상태 보장)
	var shuffled := shuffle_solvable(numbers.duplicate())
	
	# 그리드에 배치
	for i in range(grid_size):
		var row: Array = []
		for j in range(grid_size):
			row.append(shuffled[i * grid_size + j])
		puzzle_grid.append(row)
	
	# 빈 칸 위치 찾기
	for i in range(grid_size):
		for j in range(grid_size):
			if puzzle_grid[i][j] == 0:
				empty_pos = Vector2i(j, i)


## 해결 가능한 퍼즐 생성
func shuffle_solvable(numbers: Array) -> Array:
	# Fisher-Yates 셔플
	for i in range(numbers.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = numbers[i]
		numbers[i] = numbers[j]
		numbers[j] = temp
	
	# 해결 가능한지 확인하고 조정
	if not is_solvable(numbers):
		# 첫 두 숫자 교환
		var temp = numbers[0]
		numbers[0] = numbers[1]
		numbers[1] = temp
	
	return numbers


## 퍼즐 해결 가능 여부 확인
func is_solvable(numbers: Array) -> bool:
	var inversions := 0
	var flat: Array = []
	
	for num in numbers:
		if num != 0:
			flat.append(num)
	
	for i in range(flat.size()):
		for j in range(i + 1, flat.size()):
			if flat[i] > flat[j]:
				inversions += 1
	
	# 홀수 그리드: 역순이 짝수여야 함
	# 짝수 그리드: 역순 + 빈 칸 행이 홀수여야 함
	if grid_size % 2 == 1:
		return inversions % 2 == 0
	else:
		var empty_row_from_bottom = grid_size - (numbers.find(0) / grid_size)
		return (inversions + empty_row_from_bottom) % 2 == 1


## 퍼즐 UI 생성
func create_puzzle_ui() -> void:
	# 기존 버튼 제거
	for button in button_grid:
		if is_instance_valid(button):
			button.queue_free()
	button_grid.clear()
	
	# 타이틀 라벨
	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "퍼즐을 맞추세요!"
	title_label.position = Vector2(50, 120)
	title_label.size = Vector2(300, 40)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	$UILayer.add_child(title_label)
	
	# 이동 횟수 라벨
	var moves_label := Label.new()
	moves_label.name = "MovesLabel"
	moves_label.text = "이동: 0"
	moves_label.position = Vector2(50, 160)
	moves_label.size = Vector2(300, 30)
	moves_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$UILayer.add_child(moves_label)
	
	# 버튼 생성
	var button_size := 60
	var spacing := 5
	var start_x := 50
	var start_y := 200
	
	for i in range(grid_size):
		for j in range(grid_size):
			var button := Button.new()
			button.size = Vector2(button_size, button_size)
			button.position = Vector2(start_x + j * (button_size + spacing), start_y + i * (button_size + spacing))
			
			var value = puzzle_grid[i][j]
			if value == 0:
				button.text = ""
				button.disabled = true
				button.modulate = Color(0.3, 0.3, 0.3)
			else:
				button.text = str(value)
				button.pressed.connect(_on_puzzle_button_pressed.bind(Vector2i(j, i)))
			
			$GameLayer.add_child(button)
			button_grid.append(button)


## 퍼즐 버튼 클릭
func _on_puzzle_button_pressed(pos: Vector2i) -> void:
	if not is_game_active or is_paused:
		return
	
	# 인접한 빈 칸인지 확인
	if is_adjacent_to_empty(pos):
		# 타일 이동
		swap_tiles(pos)
		move_count += 1
		
		# UI 업데이트
		update_puzzle_ui()
		
		# 점수 업데이트 (이동할 때마다 감소, 최소 0)
		update_score(max(0, 100 - move_count))
		
		# 완료 확인
		if check_win():
			on_puzzle_complete()


## 인접한 빈 칸 확인
func is_adjacent_to_empty(pos: Vector2i) -> bool:
	var diff = pos - empty_pos
	return abs(diff.x) + abs(diff.y) == 1


## 타일 교환
func swap_tiles(pos: Vector2i) -> void:
	var temp = puzzle_grid[pos.y][pos.x]
	puzzle_grid[pos.y][pos.x] = 0
	puzzle_grid[empty_pos.y][empty_pos.x] = temp
	empty_pos = pos


## 퍼즐 UI 업데이트
func update_puzzle_ui() -> void:
	var moves_label = $UILayer.get_node_or_null("MovesLabel")
	if moves_label:
		moves_label.text = "이동: %d" % move_count
	
	# 버튼 텍스트 업데이트
	var index := 0
	for i in range(grid_size):
		for j in range(grid_size):
			if index < button_grid.size():
				var button = button_grid[index]
				var value = puzzle_grid[i][j]
				if value == 0:
					button.text = ""
					button.disabled = true
					button.modulate = Color(0.3, 0.3, 0.3)
				else:
					button.text = str(value)
					button.disabled = false
					button.modulate = Color.WHITE
			index += 1


## 승리 조건 확인
func check_win() -> bool:
	var expected := 1
	for i in range(grid_size):
		for j in range(grid_size):
			var value = puzzle_grid[i][j]
			if i == grid_size - 1 and j == grid_size - 1:
				# 마지막 칸은 빈 칸이어야 함
				if value != 0:
					return false
			else:
				if value != expected:
					return false
				expected += 1
	return true


## 퍼즐 완료
func on_puzzle_complete() -> void:
	# 보너스 점수
	var time_bonus := int(game_timer.time_left * 2) if game_timer else 0
	var difficulty_bonus := difficulty * 50
	update_score(current_score + time_bonus + difficulty_bonus)
	
	# 완료 메시지
	var title_label = $UILayer.get_node_or_null("TitleLabel")
	if title_label:
		title_label.text = "완료! 축하합니다!"
	
	# 게임 종료
	await get_tree().create_timer(1.0).timeout
	end()


## 게임 시작 시
func on_game_start() -> void:
	move_count = 0
	super.on_game_start()


## 게임 종료 시
func on_game_end(success: bool) -> void:
	super.on_game_end(success)


## 게임 데이터 반환
func get_game_data() -> Dictionary:
	var data := super.get_game_data()
	data["move_count"] = move_count
	data["grid_size"] = grid_size
	data["puzzle_grid"] = puzzle_grid.duplicate()
	return data


## 게임 데이터 로드
func load_game_data(data: Dictionary) -> void:
	super.load_game_data(data)
	if data.has("move_count"):
		move_count = data.move_count
	if data.has("grid_size"):
		grid_size = data.grid_size
	if data.has("puzzle_grid"):
		puzzle_grid = data.puzzle_grid.duplicate()
		# 빈 칸 위치 찾기
		for i in range(grid_size):
			for j in range(grid_size):
				if puzzle_grid[i][j] == 0:
					empty_pos = Vector2i(j, i)

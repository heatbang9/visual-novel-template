extends Node

var minigame_manager: MinigameManager

func _ready() -> void:
	minigame_manager = MinigameManager.new()
	minigame_manager.minigame_completed.connect(_on_minigame_completed)
	add_child(minigame_manager)

func start_minigame(game_name: String, difficulty: int = 1) -> void:
	minigame_manager.start_minigame(game_name, difficulty)

func _on_minigame_completed(game_name: String, success: bool, score: int) -> void:
	print("미니게임 완료: %s, 성공: %s, 점수: %d" % [game_name, success, score])
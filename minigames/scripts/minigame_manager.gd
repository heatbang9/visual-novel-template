extends Node
class_name MinigameManager

signal minigame_completed(game_name: String, success: bool, score: int)

var current_minigame: MinigameBase = null
var minigame_scenes: Dictionary = {}

func _ready() -> void:
	register_minigames()

func register_minigames() -> void:
	minigame_scenes = {
		# 기존 미니게임들
		"reaction": "res://minigames/scenes/reaction_game.tscn",
		"color_match": "res://minigames/scenes/color_match_game.tscn",
		"puzzle": "res://minigames/scenes/puzzle_game.tscn",
		"word_guess": "res://minigames/scenes/word_guess_game.tscn",
		"memory": "res://minigames/scenes/memory_game.tscn",
		"maze": "res://minigames/scenes/maze_game.tscn",
		"math": "res://minigames/scenes/math_game.tscn",
		"pattern": "res://minigames/scenes/pattern_game.tscn",
		"find_object": "res://minigames/scenes/find_object_game.tscn",
		"balance": "res://minigames/scenes/balance_game.tscn",
		"shooting": "res://minigames/scenes/shooting_game.tscn",
		"rhythm": "res://minigames/scenes/rhythm_game.tscn",
		"rotate_puzzle": "res://minigames/scenes/rotate_puzzle_game.tscn",
		"connect": "res://minigames/scenes/connect_game.tscn",
		"fishing": "res://minigames/scenes/fishing_game.tscn",
		"racing": "res://minigames/scenes/racing_game.tscn",
		"cleaning": "res://minigames/scenes/cleaning_game.tscn",
		"cooking": "res://minigames/scenes/cooking_game.tscn",
		"plant": "res://minigames/scenes/plant_game.tscn",
		"tower": "res://minigames/scenes/tower_game.tscn",
		
		# 새로운 미니게임들 (v2)
		"card_battle": "res://minigames_v2/scenes/card_battle_game.tscn",
		"dungeon_crawler": "res://minigames_v2/scenes/dungeon_crawler_game.tscn",
		"tower_defense": "res://minigames_v2/scenes/tower_defense_game.tscn",
		"log_adventure": "res://minigames_v2/scenes/log_adventure_game.tscn",
		"stack_management": "res://minigames_v2/scenes/stack_management_game.tscn",
		"pattern_breaker": "res://minigames_v2/scenes/pattern_breaker_game.tscn",
		"route_finder": "res://minigames_v2/scenes/route_finder_game.tscn",
		"chain_reaction": "res://minigames_v2/scenes/chain_reaction_game.tscn",
		"grid_control": "res://minigames_v2/scenes/grid_control_game.tscn",
		"sequence_master": "res://minigames_v2/scenes/sequence_master_game.tscn",
		"matrix_hacker": "res://minigames_v2/scenes/matrix_hacker_game.tscn",
		"particle_collector": "res://minigames_v2/scenes/particle_collector_game.tscn",
		"wave_survivor": "res://minigames_v2/scenes/wave_survivor_game.tscn",
		"node_connector": "res://minigames_v2/scenes/node_connector_game.tscn",
		"puzzle_maker": "res://minigames_v2/scenes/puzzle_maker_game.tscn",
		"spell_caster": "res://minigames_v2/scenes/spell_caster_game.tscn",
		"tetris_variant": "res://minigames_v2/scenes/tetris_variant_game.tscn",
		"line_defender": "res://minigames_v2/scenes/line_defender_game.tscn",
		"color_flow": "res://minigames_v2/scenes/color_flow_game.tscn",
		"time_manager": "res://minigames_v2/scenes/time_manager_game.tscn"
	}

func start_minigame(game_name: String, difficulty: int = 1) -> bool:
	if game_name not in minigame_scenes:
		print("미니게임을 찾을 수 없습니다: ", game_name)
		return false
	
	if current_minigame != null:
		end_current_minigame()
	
	var scene_path = minigame_scenes[game_name]
	var scene = load(scene_path)
	if scene == null:
		print("미니게임 씬을 로드할 수 없습니다: ", scene_path)
		return false
	
	current_minigame = scene.instantiate()
	current_minigame.difficulty = difficulty
	current_minigame.game_completed.connect(_on_minigame_completed)
	current_minigame.game_exited.connect(_on_minigame_exited)
	
	get_tree().current_scene.add_child(current_minigame)
	current_minigame.start_game()
	
	return true

func end_current_minigame() -> void:
	if current_minigame != null:
		current_minigame.queue_free()
		current_minigame = null

func _on_minigame_completed(success: bool, score: int) -> void:
	var game_name = current_minigame.game_name if current_minigame else ""
	minigame_completed.emit(game_name, success, score)
	end_current_minigame()

func _on_minigame_exited() -> void:
	end_current_minigame()

func get_available_games() -> Array[String]:
	return minigame_scenes.keys()

func is_game_available(game_name: String) -> bool:
	return game_name in minigame_scenes
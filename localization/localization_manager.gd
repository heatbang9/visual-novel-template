extends Node
class_name LocalizationManager

signal language_changed(new_language: String)

var current_language: String = "ko"
var translations: Dictionary = {}
var available_languages: Array[String] = ["ko", "en"]

func _ready() -> void:
	load_translations()
	set_language(current_language)

func load_translations() -> void:
	translations = {
		"ko": {
			# 기본 UI
			"back_button": "뒤로 가기",
			"score": "점수",
			"time": "시간",
			"start": "시작",
			"pause": "일시정지",
			"resume": "계속",
			"game_over": "게임 오버",
			"success": "성공",
			"failed": "실패",
			"try_again": "다시 시도",
			"next": "다음",
			
			# 기존 미니게임들
			"reaction_game_name": "반사신경 게임",
			"reaction_game_desc": "버튼이 나타나면 빠르게 클릭하세요!",
			"color_match_name": "색깔 매칭",
			"color_match_desc": "색상 순서를 기억하고 따라하세요!",
			"puzzle_game_name": "퍼즐 조각 맞추기",
			"puzzle_game_desc": "숫자를 올바른 순서로 배열하세요!",
			"word_guess_name": "단어 맞히기",
			"word_guess_desc": "힌트를 보고 단어를 맞춰보세요!",
			"memory_game_name": "기억력 테스트",
			"memory_game_desc": "같은 그림의 카드 쌍을 찾으세요!",
			"maze_game_name": "미로 탈출",
			"maze_game_desc": "화살표 키로 미로를 탈출하세요!",
			"math_game_name": "숫자 맞추기",
			"math_game_desc": "수학 문제를 풀어보세요!",
			"pattern_game_name": "패턴 따라하기",
			"pattern_game_desc": "순서대로 버튼을 클릭하세요!",
			"find_object_name": "물건 찾기",
			"find_object_desc": "숨겨진 물건들을 찾으세요!",
			"balance_game_name": "균형 맞추기",
			"balance_game_desc": "시소의 균형을 맞춰보세요!",
			"shooting_game_name": "슈팅 게임",
			"shooting_game_desc": "타겟을 클릭해서 맞추세요!",
			"rhythm_game_name": "리듬 게임",
			"rhythm_game_desc": "박자에 맞춰 스페이스바를 누르세요!",
			"rotate_puzzle_name": "돌리기 퍼즐",
			"rotate_puzzle_desc": "모든 조각을 올바른 방향으로 돌리세요!",
			"connect_game_name": "연결 게임",
			"connect_game_desc": "점들을 올바르게 연결하세요!",
			"fishing_game_name": "낚시 게임",
			"fishing_game_desc": "물고기가 물었을 때 스페이스바를 누르세요!",
			"racing_game_name": "경주 게임",
			"racing_game_desc": "장애물을 피해 결승선에 도달하세요!",
			"cleaning_game_name": "청소 게임",
			"cleaning_game_desc": "더러운 곳을 클릭해서 청소하세요!",
			"cooking_game_name": "요리 게임",
			"cooking_game_desc": "레시피 순서대로 재료를 추가하세요!",
			"plant_game_name": "식물 키우기",
			"plant_game_desc": "적절히 물을 줘서 식물을 키우세요!",
			"tower_game_name": "탑 쌓기",
			"tower_game_desc": "블록을 떨어뜨려 높은 탑을 쌓으세요!",
			
			# 새로운 미니게임들
			"card_battle_name": "카드 배틀",
			"card_battle_desc": "전략적으로 카드를 사용해 적을 물리치세요!",
			"dungeon_crawler_name": "던전 크롤러",
			"dungeon_crawler_desc": "랜덤 던전을 탐험하며 보물을 찾으세요!",
			"tower_defense_name": "타워 디펜스",
			"tower_defense_desc": "적의 침입을 막아내세요!",
			"log_adventure_name": "로그 어드벤처",
			"log_adventure_desc": "선택을 통해 모험을 진행하세요!",
			"stack_management_name": "스택 매니지먼트",
			"stack_management_desc": "리소스를 효율적으로 관리하세요!"
		},
		"en": {
			# 기본 UI
			"back_button": "Back",
			"score": "Score",
			"time": "Time",
			"start": "Start",
			"pause": "Pause",
			"resume": "Resume",
			"game_over": "Game Over",
			"success": "Success",
			"failed": "Failed",
			"try_again": "Try Again",
			"next": "Next",
			
			# 기존 미니게임들
			"reaction_game_name": "Reaction Game",
			"reaction_game_desc": "Click the button quickly when it appears!",
			"color_match_name": "Color Match",
			"color_match_desc": "Remember and follow the color sequence!",
			"puzzle_game_name": "Puzzle Game",
			"puzzle_game_desc": "Arrange the numbers in correct order!",
			"word_guess_name": "Word Guess",
			"word_guess_desc": "Guess the word from the hint!",
			"memory_game_name": "Memory Game",
			"memory_game_desc": "Find pairs of matching cards!",
			"maze_game_name": "Maze Escape",
			"maze_game_desc": "Escape the maze using arrow keys!",
			"math_game_name": "Math Game",
			"math_game_desc": "Solve math problems!",
			"pattern_game_name": "Pattern Game",
			"pattern_game_desc": "Click buttons in sequence!",
			"find_object_name": "Find Objects",
			"find_object_desc": "Find the hidden objects!",
			"balance_game_name": "Balance Game",
			"balance_game_desc": "Balance the seesaw!",
			"shooting_game_name": "Shooting Game",
			"shooting_game_desc": "Click to hit targets!",
			"rhythm_game_name": "Rhythm Game",
			"rhythm_game_desc": "Press spacebar to the beat!",
			"rotate_puzzle_name": "Rotate Puzzle",
			"rotate_puzzle_desc": "Rotate all pieces to correct direction!",
			"connect_game_name": "Connect Game",
			"connect_game_desc": "Connect the dots correctly!",
			"fishing_game_name": "Fishing Game",
			"fishing_game_desc": "Press spacebar when fish bites!",
			"racing_game_name": "Racing Game",
			"racing_game_desc": "Avoid obstacles and reach the finish line!",
			"cleaning_game_name": "Cleaning Game",
			"cleaning_game_desc": "Click to clean dirty spots!",
			"cooking_game_name": "Cooking Game",
			"cooking_game_desc": "Add ingredients in recipe order!",
			"plant_game_name": "Plant Growing",
			"plant_game_desc": "Water the plant appropriately to grow it!",
			"tower_game_name": "Tower Building",
			"tower_game_desc": "Drop blocks to build a tall tower!",
			
			# 새로운 미니게임들
			"card_battle_name": "Card Battle",
			"card_battle_desc": "Use cards strategically to defeat enemies!",
			"dungeon_crawler_name": "Dungeon Crawler",
			"dungeon_crawler_desc": "Explore random dungeons for treasure!",
			"tower_defense_name": "Tower Defense",
			"tower_defense_desc": "Defend against incoming enemies!",
			"log_adventure_name": "Log Adventure",
			"log_adventure_desc": "Progress through choices in your adventure!",
			"stack_management_name": "Stack Management",
			"stack_management_desc": "Manage resources efficiently!"
		}
	}

func set_language(language: String) -> void:
	if language in available_languages:
		current_language = language
		language_changed.emit(language)

func get_text(key: String, default_text: String = "") -> String:
	if current_language in translations and key in translations[current_language]:
		return translations[current_language][key]
	elif "en" in translations and key in translations["en"]:
		return translations["en"][key]
	else:
		return default_text if default_text != "" else key

func get_available_languages() -> Array[String]:
	return available_languages
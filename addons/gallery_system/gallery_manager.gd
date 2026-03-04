extends Node

## 갤러리 매니저
## CG, 이벤트 이미지, 배경화면 등의 갤러리 시스템 관리


signal cg_unlocked(cg_id: String)
signal cg_viewed(cg_id: String)
signal gallery_updated

# 갤러리 데이터 구조
var gallery_data: Dictionary = {
	"cg_images": {},       # CG 이미지 (스토리 이벤트 이미지)
	"backgrounds": {},    # 배경화면
	"character_sprites": {}, # 캐릭터 스프라이트
	"events": {}           # 이벤트 이미지
}

const GALLERY_FILE = "user://gallery_data.json"

func _ready() -> void:
	_load_gallery_data()

# 갤러리 데이터 로드
func _load_gallery_data() -> void:
	if FileAccess.file_exists(GALLERY_FILE):
		var file = FileAccess.open(GALLERY_FILE, FileAccess.READ)
		if file:
			var json = JSON.parse_string(file.get_as_text())
			if json:
				gallery_data = json

# 갤러리 데이터 저장
func save_gallery_data() -> void:
	var file = FileAccess.open(GALLERY_FILE, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(gallery_data))
		emit_signal("gallery_updated")

# CG 등록
func register_cg_category(category_id: String, category_name: String, cg_list: Array) -> void:
	if not gallery_data["cg_images"].has(category_id):
		gallery_data["cg_images"][category_id] = {
			"name": category_name,
			"images": {}
		}
	
	for cg in cg_list:
		if not gallery_data["cg_images"][category_id]["images"].has(cg.id):
			gallery_data["cg_images"][category_id]["images"][cg.id] = {
				"title": cg.title,
				"description": cg.description,
				"image_path": cg.image_path,
				"thumbnail_path": cg.thumbnail_path if cg.has("thumbnail_path") else cg.image_path,
				"unlocked": false,
				"viewed": false,
				"view_count": 0,
				"unlock_condition": cg.unlock_condition if cg.has("unlock_condition") else {}
			}
	
	save_gallery_data()

# CG 언락
func unlock_cg(category_id: String, cg_id: String) -> void:
	if gallery_data["cg_images"].has(category_id):
		if gallery_data["cg_images"][category_id]["images"].has(cg_id):
			if not gallery_data["cg_images"][category_id]["images"][cg_id]["unlocked"]:
				gallery_data["cg_images"][category_id]["images"][cg_id]["unlocked"] = true
				save_gallery_data()
				emit_signal("cg_unlocked", cg_id)

# CG 조회 (언락된 CG만)
func view_cg(category_id: String, cg_id: String) -> void:
	if gallery_data["cg_images"].has(category_id):
		if gallery_data["cg_images"][category_id]["images"].has(cg_id):
			var cg_data = gallery_data["cg_images"][category_id]["images"][cg_id]
			if cg_data["unlocked"]:
				cg_data["viewed"] = true
				cg_data["view_count"] += 1
				save_gallery_data()
				emit_signal("cg_viewed", cg_id)
				return cg_data
	return null

# CG 데이터 가져오기
func get_cg_data(category_id: String, cg_id: String) -> Dictionary:
	if gallery_data["cg_images"].has(category_id):
		if gallery_data["cg_images"][category_id]["images"].has(cg_id):
			return gallery_data["cg_images"][category_id]["images"][cg_id]
	return {}

# 카테고리의 모든 CG 가져오기
func get_category_cgs(category_id: String) -> Dictionary:
	if gallery_data["cg_images"].has(category_id):
		return gallery_data["cg_images"][category_id]["images"]
	return {}

# 모든 카테고리 가져오기
func get_all_categories() -> Dictionary:
	return gallery_data["cg_images"]

# 언락된 CG 개수
func get_unlocked_count(category_id: String = "") -> int:
	var count = 0
	
	if category_id.is_empty():
		# 전체 카테고리
		for category in gallery_data["cg_images"].values():
			for cg in category["images"].values():
				if cg["unlocked"]:
					count += 1
	else:
		# 특정 카테고리
		if gallery_data["cg_images"].has(category_id):
			for cg in gallery_data["cg_images"][category_id]["images"].values():
				if cg["unlocked"]:
					count += 1
	
	return count

# 전체 CG 개수
func get_total_count(category_id: String = "") -> int:
	var count = 0
	
	if category_id.is_empty():
		for category in gallery_data["cg_images"].values():
			count += category["images"].size()
	else:
		if gallery_data["cg_images"].has(category_id):
			count = gallery_data["cg_images"][category_id]["images"].size()
	
	return count

# 진행률 계산 (0.0 ~ 1.0)
func get_progress(category_id: String = "") -> float:
	var total = get_total_count(category_id)
	if total == 0:
		return 0.0
	
	var unlocked = get_unlocked_count(category_id)
	return float(unlocked) / float(total)

# 조건 기반 언락 체크
func check_unlock_conditions() -> void:
	for category_id in gallery_data["cg_images"].keys():
		for cg_id in gallery_data["cg_images"][category_id]["images"].keys():
			var cg_data = gallery_data["cg_images"][category_id]["images"][cg_id]
			if not cg_data["unlocked"] and not cg_data["unlock_condition"].is_empty():
				if _evaluate_condition(cg_data["unlock_condition"]):
					unlock_cg(category_id, cg_id)

# 조건 평가
func _evaluate_condition(condition: Dictionary) -> bool:
	if condition.is_empty():
		return false
	
	# 게임 변수 확인
	if condition.has("variable"):
		var var_name = condition["variable"]
		var required_value = condition["value"]
		var current_value = GameDataManager.get_variable(var_name)
		return current_value == required_value
	
	# 플래그 확인
	if condition.has("flag"):
		return GameDataManager.has_flag(condition["flag"])
	
	# 장면 완료 확인
	if condition.has("scene_completed"):
		return GameDataManager.has_flag("scene_" + condition["scene_completed"] + "_completed")
	
	# 업적 달성 확인
	if condition.has("achievement"):
		return AchievementManager.is_achievement_unlocked(condition["achievement"])
	
	return false

# 배경화면 등록
func register_background(bg_id: String, bg_name: String, image_path: String, unlock_condition: Dictionary = {}) -> void:
	if not gallery_data["backgrounds"].has(bg_id):
		gallery_data["backgrounds"][bg_id] = {
			"name": bg_name,
			"image_path": image_path,
			"unlocked": false,
			"unlock_condition": unlock_condition
		}
		save_gallery_data()

# 배경화면 언락
func unlock_background(bg_id: String) -> void:
	if gallery_data["backgrounds"].has(bg_id):
		if not gallery_data["backgrounds"][bg_id]["unlocked"]:
			gallery_data["backgrounds"][bg_id]["unlocked"] = true
			save_gallery_data()

# 캐릭터 스프라이트 등록
func register_character_sprite(char_id: String, sprite_name: String, image_path: String, unlock_condition: Dictionary = {}) -> void:
	if not gallery_data["character_sprites"].has(char_id):
		gallery_data["character_sprites"][char_id] = {
			"sprites": {}
		}
	
	if not gallery_data["character_sprites"][char_id]["sprites"].has(sprite_name):
		gallery_data["character_sprites"][char_id]["sprites"][sprite_name] = {
			"image_path": image_path,
			"unlocked": false,
			"unlock_condition": unlock_condition
		}
		save_gallery_data()

# 캐릭터 스프라이트 언락
func unlock_character_sprite(char_id: String, sprite_name: String) -> void:
	if gallery_data["character_sprites"].has(char_id):
		if gallery_data["character_sprites"][char_id]["sprites"].has(sprite_name):
			if not gallery_data["character_sprites"][char_id]["sprites"][sprite_name]["unlocked"]:
				gallery_data["character_sprites"][char_id]["sprites"][sprite_name]["unlocked"] = true
				save_gallery_data()

# 갤러리 초기화 (새 게임 시작 시)
func reset_gallery() -> void:
	gallery_data = {
		"cg_images": {},
		"backgrounds": {},
		"character_sprites": {},
		"events": {}
	}
	save_gallery_data()

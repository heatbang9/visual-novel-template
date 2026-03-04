extends Node

# 캐릭터 관계 관리 시스템
# 캐릭터 간의 호감도, 신뢰도, 관계 상태를 추적하고 관리

signal relationship_changed(character1_id: String, character2_id: String, relationship_type: String, new_value: float)
signal relationship_milestone_reached(character1_id: String, character2_id: String, milestone: String)
signal relationship_unlocked(character1_id: String, character2_id: String, unlock_type: String)

# 관계 데이터
var relationships: Dictionary = {}  # {char1_id: {char2_id: {type: value}}}
var relationship_metadata: Dictionary = {}  # 메타데이터 (설명, 아이콘 등)
var milestones: Dictionary = {}  # 달성한 이정표
var unlocked_relationships: Array = []  # 잠금 해제된 관계

# 설정
const MIN_AFFECTION: float = -100.0
const MAX_AFFECTION: float = 100.0
const MIN_TRUST: float = 0.0
const MAX_TRUST: float = 100.0

# 관계 타입
enum RelationshipType {
	AFFECTION,      # 호감도 (-100 to 100)
	TRUST,          # 신뢰도 (0 to 100)
	FRIENDSHIP,     # 우정 (0 to 100)
	ROMANCE,        # 로맨스 (0 to 100)
	RESPECT,        # 존경 (0 to 100)
	RIVALRY         # 라이벌 (0 to 100)
}

# 이정표 정의
var milestone_definitions: Dictionary = {
	"stranger": {"affection": (-100, -50), "description": "낯선 사람"},
	"acquaintance": {"affection": (-50, 0), "description": "아는 사이"},
	"friend": {"affection": (0, 30), "description": "친구"},
	"close_friend": {"affection": (30, 60), "description": "절친"},
	"best_friend": {"affection": (60, 80), "description": "가장 친한 친구"},
	"soulmate": {"affection": (80, 100), "description": "영혼의 반려"},
	"enemy": {"affection": (-100, -80), "description": "적"},
	"rival": {"rivalry": (50, 100), "description": "라이벌"},
	"lover": {"romance": (70, 100), "description": "연인"}
}

func _ready():
	load_relationships()

# 관계 초기화
func initialize_relationship(char1_id: String, char2_id: String, initial_values: Dictionary = {}) -> void:
	var key = _get_relationship_key(char1_id, char2_id)
	
	if not relationships.has(char1_id):
		relationships[char1_id] = {}
	
	if not relationships[char1_id].has(char2_id):
		relationships[char1_id][char2_id] = {
			"affection": 0.0,
			"trust": 0.0,
			"friendship": 0.0,
			"romance": 0.0,
			"respect": 0.0,
			"rivalry": 0.0
		}
	
	# 초기 값 적용
	for type in initial_values:
		relationships[char1_id][char2_id][type] = initial_values[type]
	
	# 양방향 관계도 생성 (기본값)
	if not relationships.has(char2_id):
		relationships[char2_id] = {}
	
	if not relationships[char2_id].has(char1_id):
		relationships[char2_id][char1_id] = relationships[char1_id][char2_id].duplicate()
	
	_check_milestones(char1_id, char2_id)
	save_relationships()

# 관계 값 변경
func modify_relationship(char1_id: String, char2_id: String, relationship_type: String, amount: float) -> void:
	if not _relationship_exists(char1_id, char2_id):
		initialize_relationship(char1_id, char2_id)
	
	var old_value = relationships[char1_id][char2_id].get(relationship_type, 0.0)
	var new_value = _clamp_relationship_value(relationship_type, old_value + amount)
	
	relationships[char1_id][char2_id][relationship_type] = new_value
	
	# 양방향 업데이트 (호감도만)
	if relationship_type == "affection" and relationships.has(char2_id) and relationships[char2_id].has(char1_id):
		relationships[char2_id][char1_id][relationship_type] = new_value
	
	emit_signal("relationship_changed", char1_id, char2_id, relationship_type, new_value)
	_check_milestones(char1_id, char2_id)
	save_relationships()

# 관계 값 설정
func set_relationship(char1_id: String, char2_id: String, relationship_type: String, value: float) -> void:
	if not _relationship_exists(char1_id, char2_id):
		initialize_relationship(char1_id, char2_id)
	
	var clamped_value = _clamp_relationship_value(relationship_type, value)
	relationships[char1_id][char2_id][relationship_type] = clamped_value
	
	# 양방향 업데이트
	if relationship_type == "affection" and relationships.has(char2_id) and relationships[char2_id].has(char1_id):
		relationships[char2_id][char1_id][relationship_type] = clamped_value
	
	emit_signal("relationship_changed", char1_id, char2_id, relationship_type, clamped_value)
	_check_milestones(char1_id, char2_id)
	save_relationships()

# 관계 값 조회
func get_relationship(char1_id: String, char2_id: String, relationship_type: String) -> float:
	if not _relationship_exists(char1_id, char2_id):
		return 0.0
	
	return relationships[char1_id][char2_id].get(relationship_type, 0.0)

# 전체 관계 조회
func get_all_relationships(char_id: String) -> Dictionary:
	if not relationships.has(char_id):
		return {}
	
	return relationships[char_id]

# 관계 이정표 확인
func _check_milestones(char1_id: String, char2_id: String) -> void:
	if not _relationship_exists(char1_id, char2_id):
		return
	
	var key = _get_relationship_key(char1_id, char2_id)
	var rel_data = relationships[char1_id][char2_id]
	
	for milestone_id in milestone_definitions:
		var milestone_def = milestone_definitions[milestone_id]
		
		for rel_type in milestone_def:
			if rel_type == "description":
				continue
			
			var range_values = milestone_def[rel_type]
			var current_value = rel_data.get(rel_type, 0.0)
			
			if current_value >= range_values[0] and current_value <= range_values[1]:
				var milestone_key = "%s_%s" % [key, milestone_id]
				
				if not milestones.has(milestone_key):
					milestones[milestone_key] = {
						"characters": [char1_id, char2_id],
						"milestone": milestone_id,
						"achieved_at": Time.get_datetime_string_from_system()
					}
					emit_signal("relationship_milestone_reached", char1_id, char2_id, milestone_id)

# 관계 잠금 해제
func unlock_relationship(char1_id: String, char2_id: String, unlock_type: String = "normal") -> void:
	var key = _get_relationship_key(char1_id, char2_id)
	
	if not key in unlocked_relationships:
		unlocked_relationships.append(key)
		emit_signal("relationship_unlocked", char1_id, char2_id, unlock_type)
		save_relationships()

# 관계 잠금 해제 확인
func is_relationship_unlocked(char1_id: String, char2_id: String) -> bool:
	var key = _get_relationship_key(char1_id, char2_id)
	return key in unlocked_relationships

# 관계 이정표 달성 확인
func has_milestone(char1_id: String, char2_id: String, milestone_id: String) -> bool:
	var key = _get_relationship_key(char1_id, char2_id)
	var milestone_key = "%s_%s" % [key, milestone_id]
	return milestones.has(milestone_key)

# 관계 설명 가져오기
func get_relationship_description(char1_id: String, char2_id: String) -> String:
	if not _relationship_exists(char1_id, char2_id):
		return "낯선 사람"
	
	var rel_data = relationships[char1_id][char2_id]
	
	# 가장 높은 관계 수치 기반 설명
	for milestone_id in milestone_definitions:
		var milestone_def = milestone_definitions[milestone_id]
		
		for rel_type in milestone_def:
			if rel_type == "description":
				continue
			
			var range_values = milestone_def[rel_type]
			var current_value = rel_data.get(rel_type, 0.0)
			
			if current_value >= range_values[0] and current_value <= range_values[1]:
				return milestone_def["description"]
	
	return "아는 사이"

# 조건 확인
func check_relationship_requirement(char1_id: String, char2_id: String, relationship_type: String, operator: String, value: float) -> bool:
	var current_value = get_relationship(char1_id, char2_id, relationship_type)
	
	match operator:
		">=": return current_value >= value
		"<=": return current_value <= value
		">": return current_value > value
		"<": return current_value < value
		"==", "=": return abs(current_value - value) < 0.01
		"!=": return abs(current_value - value) >= 0.01
	
	return false

# 저장
func save_relationships() -> void:
	var save_data = {
		"relationships": relationships,
		"milestones": milestones,
		"unlocked": unlocked_relationships
	}
	
	var file = FileAccess.open("user://relationships.save", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

# 로드
func load_relationships() -> void:
	if not FileAccess.file_exists("user://relationships.save"):
		return
	
	var file = FileAccess.open("user://relationships.save", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			relationships = data.get("relationships", {})
			milestones = data.get("milestones", {})
			unlocked_relationships = data.get("unlocked", [])

# 초기화
func reset_relationships() -> void:
	relationships.clear()
	milestones.clear()
	unlocked_relationships.clear()
	save_relationships()

# 유틸리티 함수들
func _relationship_exists(char1_id: String, char2_id: String) -> bool:
	return relationships.has(char1_id) and relationships[char1_id].has(char2_id)

func _get_relationship_key(char1_id: String, char2_id: String) -> String:
	var ids = [char1_id, char2_id]
	ids.sort()
	return "%s_%s" % [ids[0], ids[1]]

func _clamp_relationship_value(relationship_type: String, value: float) -> float:
	match relationship_type:
		"affection":
			return clamp(value, MIN_AFFECTION, MAX_AFFECTION)
		"trust", "friendship", "romance", "respect", "rivalry":
			return clamp(value, MIN_TRUST, MAX_TRUST)
	
	return value

# 통계
func get_relationship_stats(char_id: String) -> Dictionary:
	var stats = {
		"total_relationships": 0,
		"average_affection": 0.0,
		"highest_affection": {"character": "", "value": 0.0},
		"lowest_affection": {"character": "", "value": 0.0},
		"milestones_achieved": 0
	}
	
	if not relationships.has(char_id):
		return stats
	
	var total_affection = 0.0
	var char_relationships = relationships[char_id]
	stats.total_relationships = char_relationships.size()
	
	for other_id in char_relationships:
		var affection = char_relationships[other_id].get("affection", 0.0)
		total_affection += affection
		
		if affection > stats.highest_affection.value:
			stats.highest_affection = {"character": other_id, "value": affection}
		
		if stats.lowest_affection.value == 0.0 or affection < stats.lowest_affection.value:
			stats.lowest_affection = {"character": other_id, "value": affection}
	
	if stats.total_relationships > 0:
		stats.average_affection = total_affection / stats.total_relationships
	
	# 이정표 수 계산
	for milestone_key in milestones:
		if milestone_key.begins_with(char_id) or milestone_key.find(char_id) != -1:
			stats.milestones_achieved += 1
	
	return stats

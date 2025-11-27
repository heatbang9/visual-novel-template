@tool
extends EditorPlugin

const MysteryValidator = preload("res://addons/mystery_validator/mystery_scenario_validator.gd")

var dock
var validator

func _enter_tree():
	validator = MysteryValidator.new()
	add_autoload_singleton("MysteryValidator", "res://addons/mystery_validator/mystery_scenario_validator.gd")
	
	# 에디터 도크 추가 (선택사항)
	# dock = preload("res://addons/mystery_validator/validator_dock.gd").new()
	# add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)
	
	print("Mystery Scenario Validator plugin activated")

func _exit_tree():
	remove_autoload_singleton("MysteryValidator")
	# if dock:
	#     remove_control_from_docks(dock)
	print("Mystery Scenario Validator plugin deactivated")

# 메뉴에 검증 명령 추가
func _has_main_screen():
	return false

func _get_plugin_name():
	return "Mystery Validator"
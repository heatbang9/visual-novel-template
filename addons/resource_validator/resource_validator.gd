@tool
extends EditorPlugin

var resource_checker: ResourceChecker

func _enter_tree():
    resource_checker = preload("res://addons/resource_validator/resource_checker.gd").new()
    resource_checker.setup(get_editor_interface())
    add_tool_menu_item("리소스 검증 실행", validate_resources)

func _exit_tree():
    remove_tool_menu_item("리소스 검증 실행")
    resource_checker = null

func validate_resources():
    resource_checker.validate_project_resources()
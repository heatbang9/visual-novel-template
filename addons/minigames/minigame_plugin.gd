@tool
extends EditorPlugin
## 미니게임 시스템 에디터 플러그인


func _enter_tree() -> void:
	# 플러그인 초기화
	print("미니게임 시스템 플러그인 로드됨")


func _exit_tree() -> void:
	# 플러그인 정리
	print("미니게임 시스템 플러그인 언로드됨")

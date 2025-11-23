@tool
extends EditorScript

# 빌드 설정 및 배포 도구
class_name BuildConfigurator

const GAMES_CONFIG_PATH = "res://games/games_config.json"
const BUILD_CONFIG_PATH = "res://build_config.json"

# 배포 모드별 설정
enum BuildMode {
	DEVELOPMENT,
	STAGING,
	PRODUCTION
}

var build_config = {
	"mode": "development",
	"enabled_games": [],
	"target_platform": "windows",
	"version": "1.0.0",
	"build_date": "",
	"features": {
		"admin_panel": true,
		"debug_mode": true,
		"auto_update": true,
		"analytics": false
	},
	"optimization": {
		"compress_textures": false,
		"compress_audio": false,
		"strip_debug_symbols": false,
		"optimize_for_size": false
	}
}

func _run() -> void:
	print("=== Visual Novel Build Configurator ===")
	print("1. Development Build (모든 게임 포함)")
	print("2. Production Build (특정 게임만)")
	print("3. Single Game Build (단일 게임)")
	print("4. Show Current Config")
	print("5. Create Export Presets")
	
	_load_current_config()

# 현재 설정 로딩
func _load_current_config() -> void:
	if FileAccess.file_exists(BUILD_CONFIG_PATH):
		var file = FileAccess.open(BUILD_CONFIG_PATH, FileAccess.READ)
		if file:
			var json = JSON.new()
			var parse_result = json.parse(file.get_as_text())
			if parse_result == OK:
				build_config = json.data
			file.close()

# 개발 빌드 설정
func configure_development_build() -> void:
	print("=== Development Build 설정 ===")
	
	build_config.mode = "development"
	build_config.features = {
		"admin_panel": true,
		"debug_mode": true,
		"auto_update": true,
		"analytics": false
	}
	build_config.optimization = {
		"compress_textures": false,
		"compress_audio": false,
		"strip_debug_symbols": false,
		"optimize_for_size": false
	}
	
	# 모든 게임 활성화
	var games = _get_available_games()
	build_config.enabled_games = games.keys()
	
	_save_config()
	_update_project_settings()
	print("Development 빌드 설정 완료!")

# 프로덕션 빌드 설정
func configure_production_build(enabled_games: Array) -> void:
	print("=== Production Build 설정 ===")
	
	build_config.mode = "production"
	build_config.enabled_games = enabled_games
	build_config.features = {
		"admin_panel": false,
		"debug_mode": false,
		"auto_update": true,
		"analytics": true
	}
	build_config.optimization = {
		"compress_textures": true,
		"compress_audio": true,
		"strip_debug_symbols": true,
		"optimize_for_size": true
	}
	
	_save_config()
	_update_project_settings()
	_create_filtered_games_config(enabled_games)
	print("Production 빌드 설정 완료!")

# 단일 게임 빌드 설정
func configure_single_game_build(game_id: String) -> void:
	print("=== Single Game Build 설정: ", game_id, " ===")
	
	build_config.mode = "single_game"
	build_config.enabled_games = [game_id]
	build_config.features = {
		"admin_panel": false,
		"debug_mode": false,
		"auto_update": false,
		"analytics": true
	}
	build_config.optimization = {
		"compress_textures": true,
		"compress_audio": true,
		"strip_debug_symbols": true,
		"optimize_for_size": true
	}
	
	_save_config()
	_update_project_settings()
	_create_single_game_config(game_id)
	print("단일 게임 빌드 설정 완료!")

# 사용 가능한 게임 목록 가져오기
func _get_available_games() -> Dictionary:
	if not FileAccess.file_exists(GAMES_CONFIG_PATH):
		return {}
	
	var file = FileAccess.open(GAMES_CONFIG_PATH, FileAccess.READ)
	if not file:
		return {}
	
	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	file.close()
	
	if parse_result != OK:
		return {}
	
	return json.data.get("games", {})

# 필터링된 게임 설정 생성
func _create_filtered_games_config(enabled_games: Array) -> void:
	var games = _get_available_games()
	var filtered_games = {}
	
	for game_id in enabled_games:
		if games.has(game_id):
			filtered_games[game_id] = games[game_id]
			filtered_games[game_id]["enabled"] = true
	
	var filtered_config = {
		"games": filtered_games,
		"deployment": {
			"build_mode": "production",
			"enabled_games": enabled_games,
			"show_development_games": false,
			"auto_update_check": true
		}
	}
	
	var file = FileAccess.open("res://games/games_config_filtered.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(filtered_config, "\t"))
		file.close()

# 단일 게임 설정 생성
func _create_single_game_config(game_id: String) -> void:
	var games = _get_available_games()
	if not games.has(game_id):
		push_error("Game not found: " + game_id)
		return
	
	var game_data = games[game_id]
	game_data["enabled"] = true
	
	var single_config = {
		"games": {
			game_id: game_data
		},
		"deployment": {
			"build_mode": "single_game",
			"enabled_games": [game_id],
			"show_development_games": false,
			"auto_update_check": false
		}
	}
	
	var file = FileAccess.open("res://games/games_config_single.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(single_config, "\t"))
		file.close()

# 설정 저장
func _save_config() -> void:
	build_config.build_date = Time.get_datetime_string_from_system()
	
	var file = FileAccess.open(BUILD_CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(build_config, "\t"))
		file.close()

# 프로젝트 설정 업데이트
func _update_project_settings() -> void:
	# 빌드 모드 설정
	ProjectSettings.set_setting("application/config/build_mode", build_config.mode)
	ProjectSettings.set_setting("application/config/enabled_games", build_config.enabled_games)
	
	# 기능 설정
	for feature in build_config.features:
		ProjectSettings.set_setting("application/features/" + feature, build_config.features[feature])
	
	# 최적화 설정
	for opt in build_config.optimization:
		ProjectSettings.set_setting("application/optimization/" + opt, build_config.optimization[opt])
	
	ProjectSettings.save()

# Export Preset 생성
func _create_export_presets() -> void:
	print("=== Export Presets 생성 중 ===")
	
	var export_presets_content = """
[preset.0]

name="Windows Desktop"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="builds/windows/visual_novel.exe"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.0.options]

custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/embed_pck=false
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
codesign/enable=false
application/modify_resources=true
application/icon=""
application/console_wrapper_icon=""
application/icon_interpolation=4
application/file_version=""
application/product_version=""
application/company_name="Visual Novel Studio"
application/product_name="Visual Novel Collection"
application/file_description=""
application/copyright=""
application/trademarks=""
application/export_angle=0
ssh_remote_deploy/enabled=false

[preset.1]

name="Linux/X11"
platform="Linux/X11"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="builds/linux/visual_novel.x86_64"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.1.options]

custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/embed_pck=false
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
ssh_remote_deploy/enabled=false

[preset.2]

name="macOS"
platform="macOS"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path="builds/macos/visual_novel.zip"
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false

[preset.2.options]

binary_format/architecture="universal"
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
application/icon=""
application/icon_interpolation=4
application/bundle_identifier="com.visualnovelstudio.collection"
application/signature=""
application/app_category="Games"
application/short_version="1.0"
application/version="1.0"
application/copyright=""
application/copyright_localized={}
display/high_res=true
codesign/codesign=1
codesign/identity=""
codesign/certificate_file=""
codesign/certificate_password=""
codesign/entitlements/custom_file=""
codesign/entitlements/allow_jit_code_execution=false
codesign/entitlements/allow_unsigned_executable_memory=false
codesign/entitlements/allow_dyld_environment_variables=false
codesign/entitlements/disable_library_validation=false
codesign/entitlements/audio_input=false
codesign/entitlements/camera=false
codesign/entitlements/location=false
codesign/entitlements/address_book=false
codesign/entitlements/calendars=false
codesign/entitlements/photos_library=false
codesign/entitlements/apple_events=false
codesign/entitlements/debugging=false
codesign/entitlements/app_sandbox/enabled=false
codesign/entitlements/app_sandbox/network_server=false
codesign/entitlements/app_sandbox/network_client=false
codesign/entitlements/app_sandbox/device_usb=false
codesign/entitlements/app_sandbox/device_bluetooth=false
codesign/entitlements/app_sandbox/files_downloads=0
codesign/entitlements/app_sandbox/files_pictures=0
codesign/entitlements/app_sandbox/files_music=0
codesign/entitlements/app_sandbox/files_movies=0
codesign/entitlements/app_sandbox/helper_executables=[]
notarization/notarization=0
privacy/microphone_usage_description=""
privacy/camera_usage_description=""
privacy/location_usage_description=""
privacy/address_book_usage_description=""
privacy/calendar_usage_description=""
privacy/photos_library_usage_description=""
privacy/desktop_folder_usage_description=""
privacy/documents_folder_usage_description=""
privacy/downloads_folder_usage_description=""
privacy/network_volumes_usage_description=""
privacy/removable_volumes_usage_description=""
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
"""
	
	var file = FileAccess.open("res://export_presets.cfg", FileAccess.WRITE)
	if file:
		file.store_string(export_presets_content)
		file.close()
		print("Export Presets 생성 완료!")

# 빌드 스크립트 생성
func create_build_scripts() -> void:
	print("=== 빌드 스크립트 생성 중 ===")
	
	# Windows 빌드 스크립트
	var windows_script = """@echo off
echo === Visual Novel Collection Build Script ===
echo.

REM Godot 경로 설정 (사용자 환경에 맞게 수정 필요)
set GODOT_PATH="C:\\Godot\\Godot_v4.5-stable_mono_win64.exe"

echo [1/3] Development Build 생성 중...
%GODOT_PATH% --headless --export-debug "Windows Desktop" "builds/development/visual_novel_dev.exe"

echo [2/3] Production Build 생성 중...
%GODOT_PATH% --headless --export-release "Windows Desktop" "builds/production/visual_novel.exe"

echo [3/3] Single Game Builds 생성 중...
%GODOT_PATH% --headless --export-release "Windows Desktop" "builds/single/school_romance.exe"

echo.
echo 빌드 완료! builds 폴더를 확인하세요.
pause
"""
	
	var file = FileAccess.open("res://tools/build_windows.bat", FileAccess.WRITE)
	if file:
		file.store_string(windows_script)
		file.close()
	
	# Linux/Mac 빌드 스크립트
	var unix_script = """#!/bin/bash
echo "=== Visual Novel Collection Build Script ==="
echo

# Godot 경로 설정 (사용자 환경에 맞게 수정 필요)
GODOT_PATH="/usr/local/bin/godot"

echo "[1/4] Development Build 생성 중..."
$GODOT_PATH --headless --export-debug "Linux/X11" "builds/development/visual_novel_dev.x86_64"

echo "[2/4] Production Build 생성 중..."
$GODOT_PATH --headless --export-release "Linux/X11" "builds/production/visual_novel.x86_64"

echo "[3/4] macOS Build 생성 중..."
$GODOT_PATH --headless --export-release "macOS" "builds/macos/visual_novel.zip"

echo "[4/4] Single Game Builds 생성 중..."
$GODOT_PATH --headless --export-release "Linux/X11" "builds/single/school_romance.x86_64"

echo
echo "빌드 완료! builds 폴더를 확인하세요."
"""
	
	file = FileAccess.open("res://tools/build_unix.sh", FileAccess.WRITE)
	if file:
		file.store_string(unix_script)
		file.close()
	
	print("빌드 스크립트 생성 완료!")

# 배포 패키징
func create_distribution_package(game_id: String = "") -> void:
	print("=== 배포 패키지 생성 중 ===")
	
	var package_name = "visual_novel_collection"
	if not game_id.is_empty():
		package_name = game_id
	
	var dist_path = "res://dist/" + package_name + "/"
	
	# 배포 폴더 생성
	DirAccess.open("res://").make_dir_recursive("dist/" + package_name)
	
	# README 파일 생성
	var readme_content = """# """ + package_name.capitalize() + """

## 설치 방법
1. 압축 파일을 원하는 폴더에 해제
2. visual_novel.exe (또는 해당 플랫폼 실행파일) 실행

## 시스템 요구사항
- OS: Windows 10/11, macOS 10.15+, 또는 Ubuntu 18.04+
- RAM: 최소 4GB 권장
- 디스크 공간: 2GB 이상
- 그래픽: DirectX 11 또는 OpenGL 3.3 지원

## 게임 정보
- 개발: Visual Novel Studio
- 버전: """ + build_config.version + """
- 빌드 날짜: """ + build_config.build_date + """

## 문의사항
- 이메일: support@visualnovelstudio.com
- 웹사이트: https://visualnovelstudio.com
"""
	
	var readme_file = FileAccess.open(dist_path + "README.txt", FileAccess.WRITE)
	if readme_file:
		readme_file.store_string(readme_content)
		readme_file.close()
	
	print("배포 패키지 생성 완료: ", dist_path)

# 현재 설정 출력
func show_current_config() -> void:
	print("=== 현재 빌드 설정 ===")
	print("모드: ", build_config.mode)
	print("활성 게임: ", build_config.enabled_games)
	print("대상 플랫폼: ", build_config.target_platform)
	print("버전: ", build_config.version)
	print("빌드 날짜: ", build_config.build_date)
	print("기능 설정: ", build_config.features)
	print("최적화 설정: ", build_config.optimization)

# 빠른 설정 메소드들
func quick_dev_build() -> void:
	configure_development_build()

func quick_prod_build(games: Array = []) -> void:
	if games.is_empty():
		games = ["school_romance", "mystery_detective"]
	configure_production_build(games)

func quick_single_build(game_id: String) -> void:
	configure_single_game_build(game_id)
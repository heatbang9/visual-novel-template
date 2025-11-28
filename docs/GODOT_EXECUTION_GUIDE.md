# Godot 실행 및 프로젝트 검증 가이드

## 🎮 현재 프로젝트에서 Godot 실행하기

### 📍 현재 위치
```bash
# 현재 디렉토리 확인
pwd
# /home/kthgo/godot/visual/visual-novel-template
```

### 🚀 즉시 실행 명령어

#### 1. Godot 다운로드 및 실행 (한 번만)
```bash
# ARM64 시스템용 Godot 4.3 다운로드
wget -q https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.arm64.zip -O godot.zip

# 압축 해제
python3 -c "import zipfile; zipfile.ZipFile('godot.zip').extractall('.')"

# 실행 권한 부여
chmod +x Godot_v4.3-stable_linux.arm64

# 버전 확인
./Godot_v4.3-stable_linux.arm64 --version
```

#### 2. 프로젝트 열기 (GUI)
```bash
# 프로젝트 편집기로 열기
./Godot_v4.3-stable_linux.arm64 --editor .

# 또는 프로젝트 파일 직접 지정
./Godot_v4.3-stable_linux.arm64 --editor project.godot
```

#### 3. 게임 직접 실행 (플레이)
```bash
# 게임 바로 실행 (GUI)
./Godot_v4.3-stable_linux.arm64 .

# 또는 헤드리스 모드 (서버/테스트용)
./Godot_v4.3-stable_linux.arm64 --headless .
```

#### 4. 스크립트 검증 및 테스트
```bash
# 프로젝트 오류 검사
./Godot_v4.3-stable_linux.arm64 --headless --check-only .

# 특정 씬 실행
./Godot_v4.3-stable_linux.arm64 --headless res://project/MainScene.tscn
```

### 🧪 Mystery Novel 통합 검증 실행
```bash
# Mystery Novel Validator V2 실행 (향후 사용)
./Godot_v4.3-stable_linux.arm64 --headless --script addons/mystery_validator_v2/integration_validator.gd .
```

---

## 🔍 다른 프로젝트에서 Godot 실행하기

### 📁 다른 프로젝트 폴더로 이동
```bash
# 예시: 다른 Godot 프로젝트가 있는 폴더로 이동
cd /path/to/other/godot/project

# 또는 상대 경로로
cd ../other-project
```

### 🛠️ Godot 바이너리 전역 사용 설정

#### 방법 1: 심볼릭 링크 생성 (권장)
```bash
# Godot를 전역에서 사용할 수 있도록 설정
sudo ln -sf $(pwd)/Godot_v4.3-stable_linux.arm64 /usr/local/bin/godot

# 이제 어디서든 godot 명령어 사용 가능
godot --version

# 다른 프로젝트에서 실행
cd /path/to/any/other/project
godot --editor .
```

#### 방법 2: 환경변수 설정
```bash
# bashrc에 Godot 경로 추가
echo 'export PATH="/home/kthgo/godot/visual/visual-novel-template:$PATH"' >> ~/.bashrc
echo 'alias godot="/home/kthgo/godot/visual/visual-novel-template/Godot_v4.3-stable_linux.arm64"' >> ~/.bashrc

# 설정 적용
source ~/.bashrc

# 이제 어디서든 godot 사용 가능
godot --version
```

#### 방법 3: 직접 경로 지정
```bash
# 절대 경로로 Godot 실행 (어느 폴더에서든)
/home/kthgo/godot/visual/visual-novel-template/Godot_v4.3-stable_linux.arm64 --editor /path/to/other/project

# project.godot 파일이 있는 폴더에서
/home/kthgo/godot/visual/visual-novel-template/Godot_v4.3-stable_linux.arm64 .
```

---

## 🎯 다른 프로젝트 검증하기

### 📋 기본 프로젝트 검증 체크리스트

#### 1. 프로젝트 구조 확인
```bash
# 다른 프로젝트 폴더로 이동
cd /path/to/other/project

# 필수 파일 확인
ls -la project.godot  # Godot 프로젝트 파일
ls -la *.gd          # GDScript 파일들
ls -la scenes/       # 씬 폴더 (있다면)
ls -la scripts/      # 스크립트 폴더 (있다면)
```

#### 2. 프로젝트 오류 검사
```bash
# 스크립트 컴파일 오류 확인
godot --headless --check-only .

# 더 자세한 로그로 확인
godot --headless --check-only . --verbose
```

#### 3. 씬 파일 확인
```bash
# 씬 파일들 찾기
find . -name "*.tscn" -type f

# 메인 씬 확인
grep "run/main_scene" project.godot
```

#### 4. 스크립트 의존성 확인
```bash
# 모든 GDScript 파일 찾기
find . -name "*.gd" -type f

# 클래스 의존성 확인
grep -r "class_name" . --include="*.gd"
grep -r "extends" . --include="*.gd"
```

### 🧪 다른 프로젝트용 간단한 검증 스크립트

#### 범용 프로젝트 검증기 생성
```bash
# 범용 검증 스크립트 생성
cat > universal_godot_validator.gd << 'EOF'
extends SceneTree

func _ready():
    print("=== Godot 프로젝트 검증 시작 ===")
    
    # 1. 프로젝트 설정 확인
    validate_project_settings()
    
    # 2. 씬 파일 확인
    validate_scenes()
    
    # 3. 스크립트 확인
    validate_scripts()
    
    print("=== 검증 완료 ===")
    quit()

func validate_project_settings():
    print("\n1. 프로젝트 설정 검증:")
    
    var config = ConfigFile.new()
    var error = config.load("res://project.godot")
    
    if error != OK:
        print("  ✗ project.godot 파일 로드 실패")
        return
    
    print("  ✓ project.godot 파일 유효")
    
    if config.has_section_key("application", "config/name"):
        var name = config.get_value("application", "config/name")
        print("  📋 프로젝트명: ", name)
    
    if config.has_section_key("application", "run/main_scene"):
        var main_scene = config.get_value("application", "run/main_scene")
        print("  🎬 메인 씬: ", main_scene)
        
        if FileAccess.file_exists(main_scene):
            print("    ✓ 메인 씬 파일 존재")
        else:
            print("    ✗ 메인 씬 파일 없음")

func validate_scenes():
    print("\n2. 씬 파일 검증:")
    
    var scene_count = count_files_with_extension(".", ".tscn")
    print("  🎭 총 씬 파일 개수: ", scene_count)
    
    if scene_count == 0:
        print("  ⚠️  씬 파일이 없습니다")
    else:
        print("  ✓ 씬 파일 발견됨")

func validate_scripts():
    print("\n3. 스크립트 검증:")
    
    var script_count = count_files_with_extension(".", ".gd")
    print("  📜 총 스크립트 파일 개수: ", script_count)
    
    if script_count == 0:
        print("  ⚠️  GDScript 파일이 없습니다")
    else:
        print("  ✓ 스크립트 파일 발견됨")

func count_files_with_extension(dir_path: String, extension: String) -> int:
    var count = 0
    var dir = DirAccess.open(dir_path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if dir.current_is_dir() and not file_name.begins_with("."):
                count += count_files_with_extension(dir_path + "/" + file_name, extension)
            elif file_name.ends_with(extension):
                count += 1
            file_name = dir.get_next()
    
    return count
EOF

# 범용 검증 실행
godot --headless --script universal_godot_validator.gd /path/to/other/project
```

---

## 🛠️ 일반적인 Godot 프로젝트 문제 해결

### ❌ 자주 발생하는 오류와 해결법

#### 1. "Cannot load main scene" 오류
```bash
# 원인: project.godot에서 지정한 메인 씬이 없음
# 해결법: 메인 씬 경로 확인 및 수정
grep "main_scene" project.godot

# 존재하는 씬 파일 찾기
find . -name "*.tscn" | head -5
```

#### 2. 스크립트 컴파일 오류
```bash
# 오류 상세 정보 확인
godot --headless --check-only . --verbose 2>&1 | grep -i error

# 특정 스크립트 테스트
godot --headless --script path/to/script.gd .
```

#### 3. 플러그인 관련 오류
```bash
# 플러그인 폴더 확인
ls -la addons/

# 플러그인 설정 확인
find addons/ -name "plugin.cfg" -exec cat {} \;
```

#### 4. 리소스 파일 없음 오류
```bash
# 누락된 리소스 찾기
godot --headless --check-only . 2>&1 | grep -i "failed to load"

# res:// 경로 확인
grep -r "res://" . --include="*.gd" --include="*.tscn" | grep -v "#"
```

---

## 📊 프로젝트 품질 평가 가이드

### 🎯 기본 품질 체크포인트

#### A급 프로젝트 (90-100점)
- [ ] 오류 없이 실행됨
- [ ] 메인 씬이 정상 로드됨  
- [ ] 모든 스크립트 컴파일 성공
- [ ] 플러그인 오류 없음
- [ ] 리소스 파일 모두 존재

#### B급 프로젝트 (70-89점)
- [ ] 경고는 있지만 실행됨
- [ ] 대부분의 기능 작동
- [ ] 일부 리소스 누락 가능
- [ ] 마이너한 스크립트 오류

#### C급 프로젝트 (50-69점)  
- [ ] 부분적으로 실행됨
- [ ] 여러 오류 존재
- [ ] 주요 기능 일부 작동 안함

#### D급 프로젝트 (50점 미만)
- [ ] 실행 불가 또는 크래시
- [ ] 심각한 구조적 문제
- [ ] 대부분의 기능 작동 안함

---

## 🚀 다른 프로젝트 검증 실행 예시

### 예시 1: 간단한 2D 게임 프로젝트
```bash
# 프로젝트 폴더로 이동
cd ~/Games/my-2d-game

# 검증 실행
godot --headless --check-only .

# 게임 실행 테스트
godot --headless res://Main.tscn
```

### 예시 2: 다른 비주얼 노벨 프로젝트
```bash
cd ~/VN/another-novel

# 범용 검증기로 검사
godot --headless --script universal_godot_validator.gd .

# Dialogic 플러그인 확인
ls -la addons/dialogic/
```

### 예시 3: 3D 프로젝트
```bash
cd ~/3D/my-fps-game

# 3D 프로젝트 특별 검증
godot --headless --check-only . --rendering-driver opengl3

# 렌더링 설정 확인
grep -A 5 "\[rendering\]" project.godot
```

---

## 💡 팁 및 주의사항

### ⚡ 성능 최적화
- `--headless` 옵션으로 GUI 없이 빠른 검증
- `--verbose` 옵션으로 상세한 디버그 정보
- `--check-only`로 실행 없이 문법 검사만

### 🛡️ 안전한 실행
- 다른 사람 프로젝트는 항상 `--check-only`로 먼저 확인
- 자동 실행 스크립트 주의 (악성 코드 가능성)
- 백업 후 테스트 진행

### 📝 로그 관리
```bash
# 상세 로그를 파일로 저장
godot --headless --check-only . --verbose > validation_log.txt 2>&1

# 오류만 필터링
godot --headless --check-only . 2>&1 | grep -i error
```

---

**이제 어떤 Godot 프로젝트든 손쉽게 검증하고 실행할 수 있습니다! 🎮**

---

*가이드 작성일: 2024년 11월 28일*  
*Godot 버전: 4.3 (ARM64 Linux)*  
*테스트 환경: WSL2 Ubuntu*
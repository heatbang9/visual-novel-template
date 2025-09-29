# WARP.md

이 파일은 이 저장소의 코드 작업 시 WARP (warp.dev)에 대한 지침을 제공합니다.

## 프로젝트 개요

이 프로젝트는 Godot 엔진을 사용하는 비주얼 노벨 템플릿입니다. Dialogic 1.5.1 플러그인이 포함되어 있으며, 완전히 작동하는 메뉴 시스템을 갖추고 있습니다.

## 아키텍처

### 주요 컴포넌트

1. **메인 씬 (MainScene.tscn)**
   - 게임의 진입점
   - 메뉴 시스템과 주요 게임 로직을 포함

2. **Dialogic 시스템**
   - 대화형 스토리텔링을 위한 핵심 시스템
   - 캐릭터, 대화, 선택지 관리

### 프로젝트 구조
```
/
├── project.godot         - Godot 프로젝트 설정 파일
├── project/
│   └── MainScene.tscn   - 메인 씬 파일
└── .godot/              - Godot 엔진 캐시 및 설정
```

## 개발 명령어

### Godot 에디터 실행
```shell
godot -e
```

### 게임 실행
```shell
godot project.godot
```

### 프로젝트 내보내기
```shell
# Windows 빌드
godot --export "Windows Desktop" path/to/output.exe

# macOS 빌드
godot --export "Mac OSX" path/to/output.zip

# Linux 빌드
godot --export "Linux/X11" path/to/output.x86_64
```

## Dialogic 사용 가이드

- 새로운 대화/스토리 추가: Godot 에디터에서 Dialogic 탭을 열고 새 타임라인 생성
- 캐릭터 관리: Dialogic의 Character Editor를 통해 캐릭터 생성 및 편집
- 타임라인 편집: Dialogic의 Timeline Editor에서 대화, 선택지, 이벤트 관리
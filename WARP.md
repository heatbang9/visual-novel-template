# WARP.md

이 파일은 이 저장소의 코드 작업 시 WARP (warp.dev)에 대한 지침을 제공합니다.

## 프로젝트 개요

이 프로젝트는 Godot 4.5 엔진을 사용하는 비주얼 노벨 템플릿입니다. TDD (테스트 주도 개발) 방식으로 개발되며, XML 기반의 씬 관리 시스템과 객체 지향적인 캐릭터 관리 시스템을 특징으로 합니다.

### 주요 기능

1. **캐릭터 관리 시스템**
   - 각 캐릭터를 독립적인 객체로 관리
   - 캐릭터별 상태 및 속성 관리
   - 대화 시스템과의 통합

2. **XML 기반 씬 관리**
   - 씬 데이터를 XML 형식으로 저장
   - 동적 씬 로딩 및 객체 생성
   - 효율적인 리소스 관리

3. **테스트 주도 개발**
   - 각 기능별 단위 테스트 구현
   - 통합 테스트를 통한 시스템 안정성 검증
   - 지속적인 품질 관리

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

## 개발 프로세스

### 기능 개발 흐름
1. 테스트 케이스 작성
2. 기능 구현
3. 테스트 실행 및 검증
4. 코드 리팩토링
5. 빌드 확인 및 커밋
6. PR 생성 및 머지

### 테스트 실행
```shell
# 단위 테스트 실행
godot --run-tests

# 특정 테스트 실행
godot --run-tests TestName
```

### Godot 에디터 실행
```shell
# Godot 4.5 에디터 실행
"C:\Users\kthgo\OneDrive\문서\Godot_v4.5-stable_mono_windows_arm64\Godot_v4.5-stable_mono_windows_arm64\Godot_v4.5-stable_mono_windows_arm64.exe"
```

### 게임 실행
```shell
godot project.godot
```

### 자동 빌드 테스트

프로젝트의 빌드 상태를 빠르게 확인하기 위한 자동 테스트 명령어입니다. 이 명령어는 Godot 프로젝트를 10초 동안 실행하고 자동으로 종료하며, 로그를 통해 빌드 문제를 확인할 수 있습니다.

```powershell
# PowerShell에서 실행
$godot = Start-Process -FilePath "C:\Users\kthgo\OneDrive\문서\Godot_v4.5-stable_mono_windows_arm64\Godot_v4.5-stable_mono_windows_arm64\Godot_v4.5-stable_mono_windows_arm64.exe" -ArgumentList "--path", $pwd -PassThru; Start-Sleep -Seconds 10; Stop-Process -Id $godot.Id -Force
```

이 자동 테스트는 다음과 같은 경우에 반드시 실행해야 합니다:
- 새로운 기능 구현 후 빌드 확인
- 리소스 파일 추가/수정 후 확인
- PR 생성 전 최종 검증
- 메인 브랜치 머지 후 확인

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
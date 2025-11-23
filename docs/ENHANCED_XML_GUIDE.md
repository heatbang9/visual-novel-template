# 확장된 Visual Novel XML 스키마 가이드

## 개요

이 가이드는 Godot 4.5 기반 비주얼 노벨 템플릿의 확장된 XML 시나리오 형식을 설명합니다. 기본 대화와 선택지뿐만 아니라 고급 시각/음향 효과, 다국어 지원, TTS, 캐릭터 애니메이션 등 전문적인 visual novel 제작이 가능한 모든 기능을 다룹니다.

## 시스템 구조

```
addons/
├── visual_effects/          # 시각 효과 시스템
│   └── visual_director.gd
├── audio_system/           # 음향 및 TTS 시스템
│   └── audio_manager.gd
├── localization_system/    # 다국어 지원
│   └── localization_manager.gd
├── scene_system/          # 확장된 씬 로더
│   └── enhanced_scene_loader.gd
└── scenario_system/       # 시나리오 관리
    └── scenario_manager.gd
```

## 확장된 XML 구조

### 1. 씬 정의 (향상된 기능)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scene name="enhanced_scene" localization_key="scenes.intro.title">
    
    <!-- 배경 설정 (전환 효과 포함) -->
    <background type="image" 
                path="res://scenes/background/classroom.png" 
                transition="fade" 
                duration="2.0" 
                scale="1.2" 
                parallax="false"/>
    
    <!-- 전역 액션 (씬 시작 시 실행) -->
    <action type="play_bgm" duration="2.0" wait="false">
        <parameters audio_path="res://audio/bgm/school_theme.ogg" 
                   fade_in="true" 
                   loop="true"/>
    </action>
    
</scene>
```

#### 속성 설명
- `localization_key`: 다국어 지원을 위한 번역 키
- `transition`: 배경 전환 효과 (`fade`, `slide_left`, `slide_right`, `instant`)
- `duration`: 전환 시간 (초)
- `scale`: 배경 스케일 (확대/축소)
- `parallax`: 패럴랙스 효과 활성화

### 2. 캐릭터 정의 (고급 설정)

```xml
<character id="yuki" 
           name="유키" 
           default_position="right" 
           entry_animation="slide_right" 
           exit_animation="fade_out" 
           scale="0.9" 
           flip_h="false">
    
    <!-- 다양한 감정 표현 -->
    <portrait emotion="normal" 
              path="res://characters/yuki/normal.png" 
              offset_x="0" 
              offset_y="-10"/>
    <portrait emotion="happy" 
              path="res://characters/yuki/happy.png" 
              offset_x="0" 
              offset_y="-10"/>
    <portrait emotion="surprised" 
              path="res://characters/yuki/surprised.png" 
              offset_x="5" 
              offset_y="-8"/>
    
    <!-- TTS/음성 설정 -->
    <voice pitch="1.2" speed="1.0" volume="0.9"/>
    
</character>
```

#### 캐릭터 속성
- `entry_animation`: 등장 애니메이션
  - `slide_left`, `slide_right`, `slide_up`, `slide_down`
  - `fade_in`, `scale_in`, `bounce_in`, `instant`
- `exit_animation`: 퇴장 애니메이션
  - `slide_left`, `slide_right`, `fade_out`, `scale_out`, `sink_down`
- `scale`: 캐릭터 크기 (1.0 = 원본 크기)
- `flip_h`: 좌우 반전 (true/false)

#### 음성 설정
- `pitch`: 음성 피치 (0.5~2.0)
- `speed`: 말하는 속도 (0.5~2.0)
- `volume`: 음성 볼륨 (0.0~1.0)

### 3. 메시지 시스템 (다국어 지원)

```xml
<message speaker="yuki" 
         emotion="happy" 
         voice_file="res://audio/voice/yuki/greeting.ogg" 
         auto_voice="true" 
         typewriter_speed="25" 
         localization_key="scenes.intro.yuki_greeting">
    
    안녕하세요! 만나서 반가워요!
    
    <!-- 다국어 번역 -->
    <translation lang="en">Hello! Nice to meet you!</translation>
    <translation lang="ja">こんにちは！お会いできて嬉しいです！</translation>
    <translation lang="zh">你好！很高兴见到你！</translation>
    
</message>
```

#### 메시지 속성
- `voice_file`: 녹음된 음성 파일 경로
- `auto_voice`: TTS 자동 생성 여부
- `typewriter_speed`: 타이핑 효과 속도 (글자/초)
- `localization_key`: 번역 시스템 키

### 4. 액션 시스템

#### 4.1 캐릭터 액션

```xml
<!-- 캐릭터 등장 -->
<action type="character_enter" target="yuki" duration="1.2" wait="true">
    <parameters animation="slide_right" position="center"/>
</action>

<!-- 캐릭터 퇴장 -->
<action type="character_exit" target="yuki" duration="0.8" wait="true">
    <parameters animation="fade_out"/>
</action>

<!-- 캐릭터 이동 -->
<action type="character_move" target="yuki" duration="1.0" wait="true">
    <parameters to_position="left" animation="ease_in_out"/>
</action>

<!-- 감정 변경 -->
<action type="change_emotion" target="yuki" duration="0.5" wait="true">
    <parameters emotion="surprised" transition="fade"/>
</action>
```

#### 4.2 카메라 액션

```xml
<!-- 카메라 이동 -->
<action type="camera_move" target="camera" duration="2.0" wait="true">
    <parameters to_position="640,360" animation="ease_in_out"/>
</action>

<!-- 카메라 줌 -->
<action type="camera_zoom" target="camera" duration="1.5" wait="true">
    <parameters zoom_level="1.5" animation="ease_in_out"/>
</action>
```

#### 4.3 화면 효과

```xml
<!-- 화면 전환 효과 -->
<action type="screen_effect" duration="1.0" wait="true">
    <parameters effect="fade_black"/>
</action>

<!-- 화면 쉐이크 -->
<action type="screen_effect" duration="0.5" wait="false">
    <parameters effect="shake" intensity="3.0"/>
</action>

<!-- 플래시 효과 -->
<action type="screen_effect" duration="0.2" wait="false">
    <parameters effect="flash_white"/>
</action>
```

##### 화면 효과 종류
- `fade_black`: 검은색으로 페이드
- `fade_white`: 흰색으로 페이드  
- `fade_to_black`: 검은색으로 페이드인만
- `fade_from_black`: 검은색에서 페이드아웃만
- `flash_white`: 흰색 플래시
- `shake`: 화면 흔들기
- `soft_glow`: 부드러운 글로우 효과

#### 4.4 오디오 액션

```xml
<!-- BGM 재생 -->
<action type="play_bgm" duration="2.0" wait="false">
    <parameters audio_path="res://audio/bgm/romantic.ogg" 
               fade_in="true" 
               loop="true"/>
</action>

<!-- BGM 중단 -->
<action type="stop_bgm" duration="2.0" wait="false">
    <parameters fade_out="true"/>
</action>

<!-- 효과음 재생 -->
<action type="play_sfx" wait="false">
    <parameters audio_path="res://audio/sfx/bell.ogg" 
               volume="0.8" 
               pitch="1.0"/>
</action>

<!-- 음성 재생 -->
<action type="play_voice" target="yuki" wait="true">
    <parameters audio_path="res://audio/voice/yuki/laugh.ogg"/>
</action>
```

#### 4.5 대기 액션

```xml
<!-- 지정 시간 대기 -->
<wait duration="2.0"/>

<!-- 액션 대기 설정 -->
<action type="character_move" target="yuki" duration="1.0" wait="false">
    <!-- wait="false"로 설정하면 다음 액션과 동시 실행 -->
</action>
```

### 5. 조건부 액션

```xml
<!-- 선택지 결과에 따른 조건부 실행 -->
<action type="change_emotion" target="yuki" duration="0.5" wait="false" condition="choice_romantic">
    <parameters emotion="shy"/>
</action>

<action type="play_bgm" duration="2.0" wait="false" condition="route_romance">
    <parameters audio_path="res://audio/bgm/romantic_theme.ogg"/>
</action>
```

### 6. 다국어 지원 시스템

#### 6.1 번역 파일 구조

```
localization/
├── ko/
│   ├── general.json
│   ├── scenarios.json
│   └── characters.json
├── en/
│   ├── general.json
│   ├── scenarios.json
│   └── characters.json
└── ja/
    ├── general.json
    ├── scenarios.json
    └── characters.json
```

#### 6.2 번역 파일 예제 (scenarios.json)

```json
{
  "scenes": {
    "intro": {
      "title": "첫 만남",
      "yuki_greeting": "안녕하세요! 만나서 반가워요!",
      "narrator_01": "새 학기 첫날, 당신은 새로운 반에 배정되었습니다."
    }
  },
  "choices": {
    "friendly_approach": "친근하게 인사한다",
    "shy_approach": "수줍게 고개만 끄덕인다"
  }
}
```

#### 6.3 다국어 오디오 파일

```
audio/
├── voice/
│   ├── ko/
│   │   └── yuki/
│   │       ├── greeting.ogg
│   │       └── laugh.ogg
│   ├── en/
│   │   └── yuki/
│   │       ├── greeting.ogg
│   │       └── laugh.ogg
│   └── ja/
│       └── yuki/
│           ├── greeting.ogg
│           └── laugh.ogg
└── bgm/
    ├── ko/
    ├── en/
    └── ja/
```

### 7. TTS (텍스트 음성 변환) 설정

#### 7.1 캐릭터별 TTS 설정

```gdscript
# LocalizationManager에서 설정
var character_tts_settings = {
    "yuki": {
        "ko": {"voice_id": "ko-KR-Standard-A", "pitch": 1.2, "speed": 1.0},
        "en": {"voice_id": "en-US-Standard-A", "pitch": 1.1, "speed": 0.95},
        "ja": {"voice_id": "ja-JP-Standard-A", "pitch": 1.3, "speed": 1.1}
    }
}
```

#### 7.2 XML에서 TTS 활성화

```xml
<message speaker="yuki" emotion="happy" auto_voice="true" tts_enabled="true">
    텍스트가 자동으로 음성으로 변환됩니다.
</message>
```

### 8. 고급 연출 기법

#### 8.1 복잡한 씬 연출

```xml
<!-- 동시 다발적 액션 실행 -->
<action type="character_enter" target="yuki" duration="1.0" wait="false">
    <parameters animation="slide_right" position="right"/>
</action>

<action type="camera_zoom" target="camera" duration="1.0" wait="false">
    <parameters zoom_level="1.2" animation="ease_in_out"/>
</action>

<action type="play_sfx" wait="false">
    <parameters audio_path="res://audio/sfx/wind.ogg" volume="0.4"/>
</action>

<!-- 모든 액션 완료 후 대기 -->
<wait duration="1.2"/>

<message speaker="narrator">
    모든 효과가 동시에 실행된 후 이 메시지가 나타납니다.
</message>
```

#### 8.2 감정적 클라이맥스 연출

```xml
<!-- 긴장감 조성 -->
<action type="screen_effect" duration="0.1" wait="false">
    <parameters effect="shake" intensity="1.0"/>
</action>

<wait duration="0.5"/>

<!-- 캐릭터 감정 변화 -->
<action type="change_emotion" target="yuki" duration="0.3" wait="true">
    <parameters emotion="surprised"/>
</action>

<!-- 극적 효과음 -->
<action type="play_sfx" wait="false">
    <parameters audio_path="res://audio/sfx/dramatic_sting.ogg" volume="0.9"/>
</action>

<!-- 카메라 급격한 줌인 -->
<action type="camera_zoom" target="camera" duration="0.5" wait="true">
    <parameters zoom_level="1.8" animation="ease_in"/>
</action>

<message speaker="yuki" emotion="shocked" voice_file="res://audio/voice/yuki/shocked.ogg">
    그럴 수가... 믿을 수 없어요!
</message>
```

### 9. 성능 최적화 팁

#### 9.1 리소스 사전 로딩

```xml
<!-- 씬 시작 전 리소스 미리 로딩 -->
<preload>
    <audio>
        <bgm path="res://audio/bgm/school_theme.ogg"/>
        <voice path="res://audio/voice/yuki/all_lines.ogg"/>
    </audio>
    <images>
        <character path="res://characters/yuki/all_emotions.png"/>
        <background path="res://scenes/background/classroom_variants.png"/>
    </images>
</preload>
```

#### 9.2 메모리 관리

```xml
<!-- 사용하지 않는 캐릭터 정리 -->
<action type="character_cleanup" target="background_character" wait="false"/>

<!-- 오디오 캐시 정리 -->
<action type="clear_audio_cache" wait="false"/>
```

### 10. 디버깅 및 테스트

#### 10.1 개발자 모드 설정

```xml
<!-- 개발자 모드에서만 실행되는 액션 -->
<action type="debug_info" debug_only="true">
    <parameters message="현재 씬: enhanced_first_meeting"/>
</action>

<!-- 성능 모니터링 -->
<action type="performance_log" debug_only="true">
    <parameters log_memory="true" log_fps="true"/>
</action>
```

#### 10.2 XML 검증

```bash
# XML 문법 검증
xmllint --noout scenes/enhanced_example.xml

# 스키마 검증 (별도 XSD 파일 필요)
xmllint --schema visual_novel_schema.xsd scenes/enhanced_example.xml
```

### 11. 실제 사용 예제

전체적인 복잡한 씬의 예제는 `scenes/enhanced_example.xml` 파일을 참조하세요. 이 파일에는 다음 기능들이 모두 포함되어 있습니다:

- 배경 페이드 전환
- BGM 자동 재생 및 페이드
- 캐릭터 슬라이드 등장/퇴장
- 감정 변화 애니메이션
- 카메라 줌 및 이동
- 다국어 텍스트 및 음성
- 효과음 동기화
- 화면 효과 (쉐이크, 플래시 등)
- 조건부 액션 실행

### 12. 확장 가능성

현재 XML 시스템은 다음과 같은 추가 확장이 가능합니다:

- **미니게임 통합**: `<minigame>` 태그로 퍼즐/선택 게임 포함
- **인벤토리 시스템**: 아이템 획득/사용 액션
- **날씨/시간 시스템**: 배경 자동 변화
- **3D 효과**: 깊이감 있는 카메라 이동
- **라이브2D 통합**: 더 생동감 있는 캐릭터 애니메이션
- **VR/AR 지원**: 몰입형 경험

이 확장된 XML 시스템을 사용하면 상업적 수준의 고품질 visual novel을 제작할 수 있습니다.
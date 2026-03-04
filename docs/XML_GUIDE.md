# Visual Novel Template - XML 가이드

## 목차
1. [마스터 XML](#마스터-xml)
2. [씬 XML](#씬-xml)
3. [태그 참조](#태그-참조)

---

## 마스터 XML

모든 시나리오를 관리하는 메인 설정 파일입니다.

**경로:** `res://scenarios/scenarios_index.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<master_index version="2.0" game_title="My Visual Novel">
  
  <!-- 게임 메타데이터 -->
  <metadata>
    <title lang="ko">비주얼 노벨</title>
    <title lang="en">Visual Novel</title>
    <author>Your Name</author>
    <version>1.0.0</version>
  </metadata>
  
  <!-- 전역 설정 -->
  <global_settings>
    <resolution width="1280" height="720"/>
    <text_speed default="30"/>
    <audio master_volume="1.0" bgm_volume="0.7"/>
  </global_settings>
  
  <!-- 전역 변수 -->
  <global_variables>
    <variable name="player_name" type="string" default="플레이어"/>
    <variable name="affection_yuki" type="int" default="0"/>
    <variable name="secret_unlocked" type="bool" default="false"/>
  </global_variables>
  
  <!-- 시나리오 목록 -->
  <scenarios>
    <scenario id="episode1" path="res://scenarios/episode1/config.json" type="main" order="1">
      <metadata>
        <title lang="ko">에피소드 1</title>
        <thumbnail>res://scenarios/episode1/thumb.png</thumbnail>
      </metadata>
    </scenario>
  </scenarios>
  
</master_index>
```

---

## 씬 XML

### 기본 구조

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scene id="scene1" name="첫 만남" localization_key="scenes.first_meeting">
  
  <!-- 배경 -->
  <background path="res://backgrounds/classroom.png" transition="fade" duration="1.5"/>
  
  <!-- BGM -->
  <bgm path="res://audio/bgm/peaceful.ogg" fade_in="true" loop="true"/>
  
  <!-- 캐릭터 정의 -->
  <character id="yuki" name="유키" position="right" scale="0.9">
    <portrait emotion="normal" path="res://characters/yuki/normal.png"/>
    <portrait emotion="happy" path="res://characters/yuki/happy.png"/>
    <voice pitch="1.2" speed="1.0"/>
  </character>
  
  <!-- 대화 -->
  <message speaker="narrator" typewriter_speed="30">
    새 학기 첫날이다.
    <translation lang="en">It's the first day of the new semester.</translation>
  </message>
  
  <!-- 캐릭터 입장 -->
  <action type="character_enter" target="yuki" duration="1.0"/>
  
  <!-- 대화 (캐릭터) -->
  <message speaker="yuki" emotion="happy" voice_file="res://audio/voice/yuki_01.ogg">
    안녕하세요! 처음 뵙겠습니다.
    <translation lang="en">Hello! Nice to meet you.</translation>
    <ruby>안녕하세요</ruby>
  </message>
  
  <!-- 선택지 -->
  <choice_point id="first_choice" timer="10.0">
    <choice target="scene_friendly">친근하게 인사한다</choice>
    <choice target="scene_shy">수줍게 인사한다</choice>
    <choice target="scene_confident" condition="confidence>=5">자신감 있게 인사한다</choice>
  </choice_point>
  
  <!-- 화면 효과 -->
  <screen_effect type="flash" duration="0.3" color="white"/>
  <screen_effect type="shake" intensity="2.0" duration="0.5"/>
  <screen_effect type="blur" intensity="0.5"/>
  <screen_effect type="vignette" intensity="0.3"/>
  
  <!-- 카메라 -->
  <camera_zoom level="1.2" duration="1.0" animation="ease_in_out"/>
  <camera_move position="640,300" duration="1.5"/>
  <camera_shake intensity="3.0" duration="0.5"/>
  
  <!-- 파티클 -->
  <action type="particles" particle_type="cherry_blossom" duration="5.0"/>
  <action type="particles" particle_type="rain" intensity="0.8"/>
  <action type="particles" particle_type="snow" intensity="0.5"/>
  
  <!-- CG 이벤트 -->
  <cg_event id="cg_intro" path="res://cg/intro.png" type="fullscreen" pan="0,0" zoom="1.0"/>
  
  <!-- 미니게임/QTE -->
  <qte type="button_mash" timeout="5.0" success_target="scene_success" fail_target="scene_fail"/>
  
  <!-- 대기 -->
  <wait duration="1.0"/>
  
  <!-- 다음 씬 -->
  <next>scene2</next>
  
</scene>
```

---

## 태그 참조

### 배경 `<background>`

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| path | string | - | 이미지 경로 |
| transition | string | fade | fade, slide_left, slide_right, zoom |
| duration | float | 1.0 | 전환 시간 (초) |
| scale | float | 1.0 | 크기 배율 |
| blur | float | 0.0 | 블러 강도 |
| color | color | white | 색상 (color|gradient) |

### 캐릭터 `<character>`

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| id | string | - | 캐릭터 ID |
| name | string | - | 표시 이름 |
| position | string | center | left, center, right, custom |
| scale | float | 1.0 | 크기 배율 |
| opacity | float | 1.0 | 투명도 (0~1) |
| flip_h | bool | false | 좌우 반전 |
| entry_animation | string | fade_in | fade_in, slide_left, slide_right, bounce |
| exit_animation | string | fade_out | fade_out, slide_left, slide_right |
| lip_sync | bool | true | 입 모양 동기화 |
| eye_blink | bool | true | 눈 깜빡임 |

#### 하위 태그

```xml
<character id="yuki">
  <portrait emotion="normal" path="res://yuki_normal.png"/>
  <portrait emotion="happy" path="res://yuki_happy.png"/>
  <voice pitch="1.2" speed="1.0" volume="0.9"/>
  <animation lip_sync="true" eye_blink="true" breath="true"/>
</character>
```

### 메시지 `<message>`

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| speaker | string | - | 화자 (캐릭터 ID 또는 narrator) |
| text | string | - | 텍스트 내용 (본문) |
| emotion | string | normal | 감정 (캐릭터 표정) |
| localization_key | string | - | 다국어 키 |
| typewriter_speed | int | 30 | 타이핑 속도 (글자/초) |
| voice_file | string | - | 음성 파일 경로 |
| text_color | color | white | 텍스트 색상 |
| text_size | int | 16 | 텍스트 크기 |
| text_position | string | bottom | top, center, bottom |
| bold | bool | false | 굵게 |
| italic | bool | false | 기울임 |
| wait_for_input | bool | true | 입력 대기 |

#### 하위 태그

```xml
<message speaker="yuki">
  안녕하세요!
  <translation lang="en">Hello!</translation>
  <translation lang="ja">こんにちは！</translation>
  <ruby>안녕하세요</ruby>
  <effect type="shake" start="0" end="5" intensity="1.0"/>
</message>
```

### 선택지 `<choice_point>`

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| id | string | - | 선택지 ID |
| timer | float | 0.0 | 제한 시간 (0=무제한) |
| default_index | int | 0 | 기본 선택 (타이머 만료 시) |
| position | string | bottom | top, center, bottom |

#### 선택지 항목 `<choice>`

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| target | string | - | 이동할 씬 ID |
| localization_key | string | - | 다국어 키 |
| icon | string | - | 아이콘 경로 |
| condition | string | - | 조건 (variable>=value) |
| locked | bool | false | 잠김 여부 |
| hidden | bool | false | 숨김 여부 |

```xml
<choice_point id="main_choice" timer="10.0">
  <choice target="scene_a">선택지 A</choice>
  <choice target="scene_b" condition="affection>=5">선택지 B (호감도 5 이상)</choice>
  <choice target="scene_c" locked="true">???</choice>
</choice_point>
```

### 액션 `<action>`

| type | 설명 | 주요 속성 |
|------|------|-----------|
| character_enter | 캐릭터 입장 | target, position, animation |
| character_exit | 캐릭터 퇴장 | target, animation |
| change_emotion | 감정 변경 | target, emotion |
| move_character | 캐릭터 이동 | target, position, duration |
| set_variable | 변수 설정 | name, value |
| set_flag | 플래그 설정 | name, value |
| particles | 파티클 효과 | particle_type, intensity |
| stop_particles | 파티클 정지 | particle_type |
| play_animation | 애니메이션 재생 | target, animation_name |

```xml
<action type="character_enter" target="yuki" duration="1.0">
  <parameters animation="slide_right" position="right"/>
</action>

<action type="change_emotion" target="yuki">
  <parameters emotion="happy"/>
</action>

<action type="set_variable" name="affection_yuki" value="+1"/>
```

### 화면 효과 `<screen_effect>`

| type | 설명 | 속성 |
|------|------|------|
| fade | 페이드 | color, duration |
| flash | 번쩍임 | color, duration, intensity |
| shake | 흔들림 | intensity, duration |
| blur | 블러 | intensity, duration |
| vignette | 비네팅 | intensity, duration |
| tint | 색조 조절 | color, intensity |
| bloom | 블룸 | intensity, threshold |
| chromatic | 색수차 | intensity |

```xml
<screen_effect type="flash" color="white" duration="0.3"/>
<screen_effect type="shake" intensity="3.0" duration="0.5"/>
<screen_effect type="blur" intensity="0.5"/>
```

### 카메라 `<camera_*>`

```xml
<!-- 줌 -->
<camera_zoom level="1.5" duration="1.0" animation="ease_in_out"/>

<!-- 이동 -->
<camera_move position="640,300" duration="1.5"/>

<!-- 흔들기 -->
<camera_shake intensity="5.0" duration="0.5"/>

<!-- 회전 -->
<camera_rotate angle="5.0" duration="0.3"/>
```

### 오디오 `<bgm>`, `<sfx>`, `<voice>`

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| path | string | - | 오디오 파일 경로 |
| volume | float | 1.0 | 볼륨 (0~1) |
| pitch | float | 1.0 | 피치 |
| loop | bool | true | 반복 (BGM만) |
| fade_in | bool | false | 페이드 인 |
| fade_out | bool | false | 페이드 아웃 |
| fade_duration | float | 1.0 | 페이드 시간 |
| position_3d | vector3 | 0,0,0 | 3D 위치 |

```xml
<bgm path="res://audio/bgm/peaceful.ogg" fade_in="true" loop="true" volume="0.7"/>
<sfx path="res://audio/sfx/door.ogg" volume="0.8"/>
<voice path="res://audio/voice/yuki_01.ogg"/>
<stop_bgm fade_out="true" fade_duration="2.0"/>
```

### CG 이벤트 `<cg_event>`

| 속성 | 타입 | 기본값 | 설명 |
|------|------|--------|------|
| id | string | - | CG ID (갤러리용) |
| path | string | - | 이미지 경로 |
| type | string | fullscreen | fullscreen, overlay, background |
| pan | vector2 | 0,0 | 패닝 위치 |
| zoom | float | 1.0 | 줌 레벨 |
| filter | string | - | 필터 (sepia, grayscale, etc.) |
| duration | float | 0 | 표시 시간 (0=수동) |

```xml
<cg_event id="cg_romantic" path="res://cg/romantic.png" type="fullscreen" pan="0,100" zoom="1.2"/>
```

### QTE/미니게임 `<qte>`, `<minigame>`

```xml
<qte type="button_mash" timeout="5.0" success_target="scene_win" fail_target="scene_lose">
  <parameters button="A" required_presses="10"/>
</qte>

<qte type="timing_bar" timeout="3.0">
  <parameters target_zone="0.7,0.9"/>
</qte>

<minigame type="puzzle" id="puzzle_01">
  <parameters difficulty="easy" rows="3" cols="3"/>
</minigame>
```

### 조건부 실행

```xml
<!-- 조건부 액션 -->
<action type="change_emotion" target="yuki" condition="affection_yuki>=5">
  <parameters emotion="happy"/>
</action>

<!-- if 문 -->
<if variable="secret_unlocked" operator="==" value="true">
  <message>비밀 루트입니다!</message>
  <action type="unlock_achievement" id="secret_finder"/>
</if>
```

---

## 전체 예시

```xml
<?xml version="1.0" encoding="UTF-8"?>
<scene id="complete_example" name="완전한 예시">
  
  <!-- 배경 설정 -->
  <background path="res://bg/school.png" transition="fade" duration="2.0"/>
  
  <!-- BGM 시작 -->
  <bgm path="res://audio/bgm/school.ogg" fade_in="true" loop="true"/>
  
  <!-- 환경음 -->
  <sfx path="res://audio/sfx/crowd.ogg" volume="0.3" loop="true"/>
  
  <!-- 캐릭터 정의 -->
  <character id="yuki" name="유키" position="right" scale="0.9" entry_animation="slide_right">
    <portrait emotion="normal" path="res://char/yuki/normal.png"/>
    <portrait emotion="happy" path="res://char/yuki/happy.png"/>
    <portrait emotion="sad" path="res://char/yuki/sad.png"/>
    <voice pitch="1.1" speed="1.0"/>
  </character>
  
  <!-- 나레이션 -->
  <message speaker="narrator" typewriter_speed="25">
    방과 후, 교실에는 한 명의 학생만 남아있었다.
    <translation lang="en">After school, only one student remained in the classroom.</translation>
  </message>
  
  <!-- 카메라 줌인 -->
  <camera_zoom level="1.3" duration="1.5" animation="ease_in_out"/>
  
  <!-- 캐릭터 입장 -->
  <action type="character_enter" target="yuki" duration="1.0"/>
  
  <!-- 파티클 효과 -->
  <action type="particles" particle_type="dust" intensity="0.3"/>
  
  <!-- 대화 -->
  <message speaker="yuki" emotion="normal" typewriter_speed="30">
    아, 안녕하세요!
    <translation lang="en">Oh, hello!</translation>
  </message>
  
  <!-- 감정 변경 -->
  <action type="change_emotion" target="yuki">
    <parameters emotion="happy" transition="fade"/>
  </action>
  
  <message speaker="yuki" emotion="happy">
    기다리고 있었어요.
  </message>
  
  <!-- 화면 효과 - 하트 -->
  <screen_effect type="particles" particle_type="hearts" intensity="0.5" duration="2.0"/>
  
  <!-- 선택지 -->
  <choice_point id="response_choice">
    <choice target="scene_friendly">반가워요!</choice>
    <choice target="scene_shy">아, 저도요...</choice>
    <choice target="scene_cool" condition="confidence>=5" icon="res://ui/icon_star.png">별일 아니에요</choice>
  </choice_point>
  
  <!-- CG 이벤트 -->
  <cg_event id="cg_first_meeting" path="res://cg/first_meeting.png" duration="3.0"/>
  
  <!-- QTE -->
  <qte type="timing_bar" timeout="3.0" success_target="scene_qte_success" fail_target="scene_qte_fail">
    <parameters speed="1.5" target_zone="0.6,0.8"/>
  </qte>
  
  <!-- 변수 변경 -->
  <action type="set_variable" name="affection_yuki" value="+1"/>
  <action type="set_flag" name="met_yuki" value="true"/>
  
  <!-- 업적 -->
  <action type="unlock_achievement" id="first_meeting"/>
  
  <!-- 갤러리 언락 -->
  <action type="unlock_cg" id="cg_first_meeting"/>
  
  <!-- 대기 -->
  <wait duration="1.0"/>
  
  <!-- BGM 전환 -->
  <bgm path="res://audio/bgm/romantic.ogg" fade_in="true" fade_duration="2.0"/>
  
  <!-- 다음 씬 -->
  <next>scene_next_day</next>
  
</scene>
```

---

## 지원 기능 요약

### 캐릭터
- ✅ 입장/퇴장 애니메이션
- ✅ 감정/표정 변경
- ✅ 위치 이동
- ✅ 크기/투명도 조절
- ✅ 좌우 반전
- ✅ 입 모양 동기화 (lip sync)
- ✅ 눈 깜빡임
- ✅ 떨림 효과

### 화면 효과
- ✅ 페이드 (색상 지정)
- ✅ 플래시
- ✅ 흔들기
- ✅ 블러
- ✅ 비네팅
- ✅ 색조 조절
- ✅ 블룸
- ✅ 파티클 (눈, 비, 벚꽃, 먼지 등)

### 카메라
- ✅ 줌인/줌아웃
- ✅ 패닝 (이동)
- ✅ 흔들기
- ✅ 회전
- ✅ 이징 애니메이션

### 텍스트
- ✅ 타이핑 효과
- ✅ 색상/크기/스타일
- ✅ 루비 텍스트
- ✅ 다국어
- ✅ 텍스트 효과 (흔들림, 파동 등)

### 오디오
- ✅ BGM (페이드, 크로스페이드)
- ✅ 효과음
- ✅ 음성
- ✅ 환경음
- ✅ 3D 포지셔닝

### 선택지
- ✅ 조건부 선택지
- ✅ 타이머
- ✅ 잠긴/숨겨진 선택지
- ✅ 아이콘

### 시스템
- ✅ CG 이벤트
- ✅ QTE/미니게임
- ✅ 업적
- ✅ 갤러리 언락
- ✅ 변수/플래그
- ✅ 세이브 포인트

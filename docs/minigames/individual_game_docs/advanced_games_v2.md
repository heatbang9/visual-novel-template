# 고급 미니게임 (V2) 상세 문서

## 1. 카드 배틀 (Card Battle Game)

### 📝 게임 설명
전략적 카드 게임으로 적과 턴제 배틀을 벌이는 게임입니다.

### 🎮 게임 플레이
- 덱에서 카드를 뽑아 사용
- 공격, 치료, 방어, 강공격 카드 유형
- 적의 체력을 0으로 만들면 승리

### 🎯 로그라이크 요소
- 랜덤 카드 덱 생성
- 각 카드의 비용과 효과가 약간씩 변화
- 적의 패턴이 매번 다름

### 🎨 필요 리소스
```
assets/cards/
  ├── card_attack.png (공격 카드)
  ├── card_heal.png (치료 카드)
  ├── card_shield.png (방어 카드)
  ├── card_heavy.png (강공격 카드)
  └── card_back.png (카드 뒷면)

assets/sounds/battle/
  ├── card_play.ogg (카드 사용)
  ├── attack_hit.ogg (공격 명중)
  ├── heal_effect.ogg (치료 효과)
  └── battle_victory.ogg (전투 승리)

assets/ui/battle/
  ├── health_bar.png (체력바)
  ├── mana_bar.png (마나바)
  └── battlefield.png (전장 배경)
```

---

## 2. 던전 크롤러 (Dungeon Crawler Game)

### 📝 게임 설명
무작위 생성된 던전을 탐험하여 보물을 찾는 게임입니다.

### 🎮 게임 플레이
- WASD로 던전 내 이동
- 보물 발견 시 점수 획득
- 적과 마주치면 확률적으로 게임오버
- 모든 보물을 찾으면 승리

### 🎯 로그라이크 요소
- 던전 레이아웃이 매번 다름
- 보물과 적의 위치 무작위 배치
- 던전 크기가 난이도에 따라 변화

### 🎨 필요 리소스
```
assets/dungeon/
  ├── wall_01.png ~ wall_05.png (다양한 벽)
  ├── floor_01.png ~ floor_03.png (바닥 타일)
  ├── treasure_chest.png (보물상자)
  └── enemy_sprite.png (적 스프라이트)

assets/characters/
  ├── player_idle.png (플레이어 대기)
  ├── player_walk_01.png ~ player_walk_04.png (걷기 애니메이션)
  └── player_minimap.png (미니맵 아이콘)

assets/sounds/dungeon/
  ├── footstep_stone.ogg (돌 바닥 걸음)
  ├── treasure_found.ogg (보물 발견)
  ├── enemy_encounter.ogg (적 조우)
  └── dungeon_ambient.ogg (던전 환경음)

assets/particles/
  ├── treasure_sparkle.png (보물 반짝임)
  └── dust_particle.png (먼지 파티클)
```

---

## 3. 타워 디펜스 (Tower Defense Game)

### 📝 게임 설명
경로를 따라 오는 적들을 타워로 방어하는 전략 게임입니다.

### 🎮 게임 플레이
- 마우스 클릭으로 타워 설치
- 여러 웨이브의 적을 막아내야 함
- 모든 웨이브를 막으면 승리

### 🎯 로그라이크 요소
- 적의 경로가 약간씩 변화
- 타워의 성능이 랜덤하게 조정
- 웨이브 구성이 매번 다름

### 🎨 필요 리소스
```
assets/towers/
  ├── basic_tower.png (기본 타워)
  ├── cannon_tower.png (캐논 타워)
  ├── laser_tower.png (레이저 타워)
  └── tower_base.png (타워 베이스)

assets/enemies/
  ├── enemy_basic.png (기본 적)
  ├── enemy_fast.png (빠른 적)
  ├── enemy_tank.png (탱크 적)
  └── enemy_boss.png (보스 적)

assets/projectiles/
  ├── bullet.png (일반 총알)
  ├── cannonball.png (대포알)
  ├── laser_beam.png (레이저 빔)
  └── explosion.png (폭발 이펙트)

assets/sounds/td/
  ├── tower_shoot.ogg (타워 발사)
  ├── enemy_hit.ogg (적 피격)
  ├── enemy_death.ogg (적 처치)
  ├── tower_build.ogg (타워 건설)
  └── wave_start.ogg (웨이브 시작)

assets/ui/td/
  ├── wave_indicator.png (웨이브 표시기)
  ├── tower_button.png (타워 버튼)
  └── upgrade_panel.png (업그레이드 패널)
```

---

## 4. 로그 어드벤처 (Log Adventure Game)

### 📝 게임 설명
텍스트 기반 어드벤처로 선택지를 통해 스토리를 진행하는 게임입니다.

### 🎮 게임 플레이
- 시나리오 읽고 선택지 중 하나 선택
- 선택에 따라 결과가 달라짐
- 여러 선택을 통해 최종 목표 달성

### 🎯 로그라이크 요소
- 시나리오가 무작위로 선택됨
- 선택지의 결과가 확률적으로 변화
- 매번 다른 스토리 경험

### 🎨 필요 리소스
```
assets/adventure/
  ├── story_background.png (스토리 배경)
  ├── choice_button_normal.png (선택지 버튼)
  ├── choice_button_hover.png (선택지 호버)
  └── result_panel.png (결과 패널)

assets/icons/adventure/
  ├── treasure_icon.png (보물 아이콘)
  ├── danger_icon.png (위험 아이콘)
  ├── safe_icon.png (안전 아이콘)
  └── mystery_icon.png (신비 아이콘)

assets/sounds/adventure/
  ├── page_turn.ogg (페이지 넘김)
  ├── choice_select.ogg (선택지 선택)
  ├── treasure_get.ogg (보물 획득)
  ├── danger_encounter.ogg (위험 조우)
  └── adventure_ambient.ogg (모험 환경음)

assets/data/adventure/
  ├── scenarios.json (시나리오 데이터)
  └── outcomes.json (결과 데이터)
```

---

## 5. 스택 매니지먼트 (Stack Management Game)

### 📝 게임 설명
제한된 시간 내에 자원을 효율적으로 관리하는 게임입니다.

### 🎮 게임 플레이
- 나무, 돌, 음식 등 자원 수집
- 일정 주기마다 자원 소모
- 목표량의 자원을 모으면 승리

### 🎯 로그라이크 요소
- 자원 수집량이 랜덤하게 변화
- 소모량이 예측하기 어렵게 변동
- 이벤트가 무작위로 발생

### 🎨 필요 리소스
```
assets/resources/
  ├── wood_icon.png (나무 아이콘)
  ├── stone_icon.png (돌 아이콘)
  ├── food_icon.png (음식 아이콘)
  ├── wood_pile.png (나무 더미)
  ├── stone_pile.png (돌 더미)
  └── food_storage.png (음식 저장소)

assets/ui/management/
  ├── resource_bar.png (자원바)
  ├── gather_button.png (수집 버튼)
  ├── day_counter.png (일수 카운터)
  └── target_panel.png (목표 패널)

assets/sounds/management/
  ├── chop_wood.ogg (나무 베기)
  ├── mine_stone.ogg (돌 채굴)
  ├── gather_food.ogg (음식 수집)
  ├── day_pass.ogg (하루 지남)
  └── resource_low.ogg (자원 부족 경고)
```

---

## 6-20. 추가 고급 게임들

### 🎮 공통 특징
나머지 고급 게임들(패턴 브레이커, 루트 파인더, 체인 리액션 등)은 다음과 같은 공통 특징을 가집니다:

- **복잡한 게임 로직**: 단순 클릭을 넘어선 전략적 사고 요구
- **동적 난이도**: 플레이어의 실력에 따라 자동 조정
- **로그라이크 요소**: 매번 다른 경험을 위한 랜덤 생성
- **시각적 피드백**: 화려한 이펙트와 애니메이션

### 🎨 공통 리소스 요구사항
```
assets/particles/advanced/
  ├── particle_01.png ~ particle_20.png (다양한 파티클)
  ├── explosion_01.png ~ explosion_05.png (폭발 이펙트)
  └── glow_effect.png (글로우 이펙트)

assets/shaders/
  ├── outline.gdshader (외곽선 셰이더)
  ├── glow.gdshader (글로우 셰이더)
  ├── wave.gdshader (웨이브 셰이더)
  └── distortion.gdshader (왜곡 셰이더)

assets/sounds/advanced/
  ├── power_up.ogg (파워업)
  ├── chain_reaction.ogg (연쇄반응)
  ├── puzzle_solve.ogg (퍼즐 해결)
  ├── level_complete.ogg (레벨 완료)
  └── combo_sound.ogg (콤보 사운드)

assets/ui/advanced/
  ├── progress_bar_fill.png (진행바 채움)
  ├── combo_counter.png (콤보 카운터)
  ├── multiplier_display.png (배수 표시)
  └── special_effect_panel.png (특수 효과 패널)
```

## 성능 및 최적화

### 🚀 고급 게임 최적화 팁

1. **오브젝트 풀링**
```gdscript
# 파티클이나 적 등 반복 생성되는 오브젝트에 적용
var object_pool: Array[Node] = []

func get_pooled_object() -> Node:
    if object_pool.is_empty():
        return create_new_object()
    return object_pool.pop_back()
```

2. **LOD (Level of Detail) 시스템**
```gdscript
# 거리에 따른 품질 조절
func update_lod(distance: float) -> void:
    if distance > 100:
        set_low_quality()
    elif distance > 50:
        set_medium_quality()
    else:
        set_high_quality()
```

3. **배치 렌더링**
- 같은 텍스처의 오브젝트들을 함께 렌더링
- MultiMesh 사용으로 드로우 콜 최소화

### 🎯 메모리 관리
- 게임 종료 시 모든 리소스 명시적 해제
- 텍스처 스트리밍으로 메모리 사용량 조절
- 가비지 컬렉션 최적화를 위한 오브젝트 재사용

## 확장성 고려사항

### 🔧 모듈러 설계
각 미니게임은 독립적으로 동작하도록 설계되어 있어:
- 개별 게임 수정이 다른 게임에 영향 없음
- 새로운 게임 추가가 용이함
- 개별 게임을 별도 프로젝트로 분리 가능

### 🌐 다국어 확장
현재 한국어/영어 지원을 다음 언어로 확장 가능:
- 일본어 (ja)
- 중국어 간체 (zh-CN)
- 스페인어 (es)
- 프랑스어 (fr)

### 📱 플랫폼 확장
- 모바일 터치 입력 지원
- 콘솔 컨트롤러 입력 지원
- VR/AR 플랫폼 적응 가능
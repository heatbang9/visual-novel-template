# 리소스 파일 가이드

## 📁 리소스 구조

### 캐릭터 스프라이트
```
characters/
├── junho/                    # 주인공 이준호
│   ├── curious.png          # 호기심 표정 (400x600px)
│   ├── thoughtful.png       # 생각하는 표정 (400x600px) 
│   ├── determined.png       # 결심한 표정 (400x600px)
│   ├── polite.png          # 공손한 표정 (400x600px)
│   ├── observant.png       # 관찰하는 표정 (400x600px)
│   └── concerned.png       # 걱정하는 표정 (400x600px)
├── park_youngsu/           # 카페 사장 박영수  
│   ├── tired.png          # 지친 표정 (400x600px)
│   ├── worried.png        # 걱정하는 표정 (400x600px)
│   └── grateful.png       # 고마워하는 표정 (400x600px)
├── kang_minho/            # 단골 고객 강민호
│   ├── normal.png         # 평소 표정 (400x600px)
│   ├── suspicious.png     # 의심스러운 표정 (400x600px)
│   └── helpful.png        # 도움주는 표정 (400x600px)
└── soyeon/               # 실종된 딸 소연
    ├── happy.png         # 행복한 표정 (400x600px)
    ├── worried.png       # 걱정하는 표정 (400x600px)
    └── grateful.png      # 고마워하는 표정 (400x600px)
```

### 배경 이미지
```
backgrounds/
├── school_gate.png       # 학교 정문 (1920x1080px)
├── cafe_interior.png     # 카페 내부 (1920x1080px)  
├── cafe_exterior.png     # 카페 외부 (1920x1080px)
├── academy_building.png  # 학원 건물 (1920x1080px)
├── academy_room.png      # 학원 강의실 (1920x1080px)
├── counseling_center.png # 여성상담센터 (1920x1080px)
├── empty_classroom.png   # 빈 교실 (1920x1080px)
└── library_basement.png  # 도서관 지하 (1920x1080px)
```

### 오디오 파일
```
audio/
├── bgm/                          # 배경음악 (OGG Vorbis)
│   ├── daily_life_theme.ogg     # 일상 테마 (루프)
│   ├── cafe_ambient.ogg         # 카페 분위기 (루프)
│   ├── mystery_theme.ogg        # 미스터리 테마 (루프)
│   ├── investigation_theme.ogg  # 수사 테마 (루프)
│   ├── tension_building.ogg     # 긴장감 조성 (루프)
│   └── emotional_resolution.ogg # 감동적 해결 (루프)
├── sfx/                         # 효과음 (OGG Vorbis)
│   ├── door_bell.ogg           # 문종소리 (0.5초)
│   ├── coffee_machine.ogg      # 커피머신 (2초)
│   ├── coffee_ready.ogg        # 커피 완성 (1초)
│   ├── phone_vibration.ogg     # 핸드폰 진동 (1초)
│   ├── paper_rustle.ogg        # 종이 바스락 (0.8초)
│   ├── footsteps.ogg           # 발걸음 (루프)
│   ├── door_open.ogg           # 문 열기 (0.7초)
│   ├── door_close.ogg          # 문 닫기 (0.7초)
│   └── dramatic_sting.ogg      # 극적 효과음 (1.5초)
└── voice/                      # 음성 파일 (다국어)
    ├── ko/                    # 한국어 음성
    │   ├── junho/             # 준호 음성
    │   ├── park_youngsu/      # 박영수 음성  
    │   ├── kang_minho/        # 강민호 음성
    │   └── soyeon/            # 소연 음성
    ├── en/                    # 영어 음성 (향후)
    └── ja/                    # 일본어 음성 (향후)
```

### UI 요소
```
ui/
├── dialogue_box.png       # 대화 상자 (1920x300px)
├── choice_button.png      # 선택지 버튼 (400x80px)
├── name_plate.png         # 이름표 (300x60px)
├── menu_background.png    # 메뉴 배경 (1920x1080px)
├── save_slot.png          # 저장 슬롯 (400x200px)
└── stats_panel.png        # 능력치 패널 (300x400px)
```

## 🎨 아트 스타일 가이드

### 캐릭터 스프라이트
- **스타일**: 애니메이션 스타일, 부드러운 셰딩
- **해상도**: 400x600px (표준)
- **색상**: 따뜻하고 자연스러운 톤
- **표정**: 각 감정별로 눈, 입, 눈썹 변화

### 배경
- **스타일**: 사실적이지만 부드러운 느낌
- **해상도**: 1920x1080px (Full HD)
- **조명**: 시간대와 상황에 맞는 자연스러운 조명
- **분위기**: 각 장소의 특성을 잘 드러내는 색감

### UI
- **스타일**: 깔끔하고 현대적
- **투명도**: 배경이 보이도록 적절한 투명도 적용
- **폰트**: 읽기 쉬운 한글 폰트 (Noto Sans KR 추천)

## 🔧 기술적 요구사항

### 이미지 포맷
- **PNG**: 투명도가 필요한 캐릭터, UI 요소
- **JPG**: 배경 이미지 (용량 절약)

### 오디오 포맷  
- **OGG Vorbis**: Godot 최적화 형식
- **비트레이트**: BGM 192kbps, SFX 128kbps, Voice 160kbps

### 파일명 규칙
- 소문자 사용
- 언더스코어(_)로 단어 구분  
- 확장자 필수
- 한글 파일명 금지

## 📋 현재 상태

### ✅ 구조 생성 완료
- [x] 폴더 구조 생성
- [x] README 문서 작성
- [x] 파일명 규칙 정의

### 🔄 제작 필요
- [ ] 캐릭터 스프라이트 제작/수집
- [ ] 배경 이미지 제작/수집  
- [ ] 오디오 파일 제작/수집
- [ ] UI 요소 디자인

### 📝 플레이스홀더 생성 예정
실제 리소스 파일이 준비되기 전까지 플레이스홀더 파일을 생성하여 개발 진행
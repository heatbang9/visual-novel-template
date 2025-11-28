# 이준호 탐정 시리즈 - 다음 단계 실행 로드맵

## 🎯 현재 상태 요약 (2024년 11월 28일)

✅ **완료된 기반 시스템**
- XML 시나리오 시스템 (100% 구현)
- 캐릭터 시스템 (20명+ 프로필 완성)
- 미니게임 시스템 (40개 게임 확인)
- TDD 검증 체계 (자동화 완료)
- 프로젝트 구조 (완전 정리)

🎮 **즉시 실행 가능한 상태**: A+ 등급 프로젝트

---

## 🚀 단계별 실행 로드맵

### Phase 1: 기본 에셋 제작 (1주차)
**목표**: 게임을 실제로 플레이할 수 있는 상태 완성

#### 1.1 캐릭터 스프라이트 제작 (2일)
```bash
# 필요한 파일들
mystery_novel/projects/junho_detective_series/resources/characters/
├── junho/
│   ├── curious.png      # 호기심 표정
│   ├── thoughtful.png   # 생각하는 표정  
│   ├── determined.png   # 결심한 표정
│   ├── polite.png       # 공손한 표정
│   ├── observant.png    # 관찰하는 표정
│   └── concerned.png    # 걱정하는 표정
├── park_youngsu/
│   ├── tired.png        # 지친 표정
│   ├── worried.png      # 걱정하는 표정
│   └── grateful.png     # 고마워하는 표정
├── kang_minho/
│   ├── normal.png       # 평소 표정
│   ├── suspicious.png   # 의심스러운 표정
│   └── helpful.png      # 도움주는 표정
└── soyeon/
    ├── happy.png        # 행복한 표정
    ├── worried.png      # 걱정하는 표정
    └── grateful.png     # 고마워하는 표정
```

**실행 방법**:
1. AI 이미지 생성 도구 활용 (Stable Diffusion, DALL-E 등)
2. 무료 캐릭터 생성 사이트 (Picrew, VRoid 등) 
3. 픽셀아트 도구 (Aseprite, Piskel 등)
4. 일러스트 외주 (Fiverr, 크몽 등)

#### 1.2 배경 이미지 제작 (2일)
```bash
# 필요한 배경들 (1920x1080px)
mystery_novel/projects/junho_detective_series/resources/backgrounds/
├── school_gate.png      # 학교 정문
├── cafe_interior.png    # 카페 내부
├── cafe_exterior.png    # 카페 외부
├── academy_building.png # 학원 건물
├── academy_room.png     # 학원 강의실
├── counseling_center.png# 여성상담센터
├── empty_classroom.png  # 빈 교실
└── library_basement.png # 도서관 지하
```

**리소스 추천**:
- 무료 배경: Unsplash, Pixabay
- 애니메이션 배경: OpenGameArt, itch.io
- AI 생성: Midjourney, Stable Diffusion

#### 1.3 기본 UI 요소 (1일)
- 대화창, 이름표, 선택지 버튼
- 메뉴 배경, 저장 슬롯 디자인
- 간단한 아이콘들

#### 1.4 첫 번째 플레이어블 빌드 (2일)
- Episode 2 완전 플레이 가능
- 기본 에셋으로 전체 시나리오 진행
- 버그 수정 및 밸런스 조정

### Phase 2: 콘텐츠 확장 (2주차)
**목표**: 게임의 볼륨과 완성도 극대화

#### 2.1 오디오 시스템 완성 (3일)
```bash
# BGM 파일들 (OGG Vorbis 192kbps)
mystery_novel/projects/junho_detective_series/resources/audio/bgm/
├── daily_life_theme.ogg     # 일상 테마 (2-3분, 루프)
├── cafe_ambient.ogg         # 카페 분위기 (환경음)
├── mystery_theme.ogg        # 미스터리 테마 (긴장감)
├── investigation_theme.ogg  # 수사 테마 (집중)
├── tension_building.ogg     # 긴장감 조성 (클라이맥스)
└── emotional_resolution.ogg # 감동적 해결 (엔딩)

# SFX 파일들 (OGG Vorbis 128kbps)
mystery_novel/projects/junho_detective_series/resources/audio/sfx/
├── door_bell.ogg           # 문종소리 (0.5초)
├── coffee_machine.ogg      # 커피머신 (2초)
├── coffee_ready.ogg        # 커피 완성 (1초)
├── phone_vibration.ogg     # 핸드폰 진동 (1초)
├── paper_rustle.ogg        # 종이 바스락 (0.8초)
├── footsteps.ogg           # 발걸음 (루프 가능)
├── door_open.ogg           # 문 열기 (0.7초)
├── door_close.ogg          # 문 닫기 (0.7초)
└── dramatic_sting.ogg      # 극적 효과음 (1.5초)
```

**오디오 리소스**:
- 무료 음악: Freesound, Zapsplat, YouTube Audio Library
- 로열티 프리: Artlist, Epidemic Sound
- AI 생성: AIVA, Soundraw

#### 2.2 Episode 3, 5 XML 변환 (2일)
- 기존 마크다운을 XML 형식으로 변환
- 선택지 시스템 및 변수 연동 구현
- 미니게임 통합 포인트 추가

#### 2.3 추가 대화 씬 구현 (2일) 
- Episode 2의 나머지 씬들 XML로 완성
- discover_cipher.xml, kang_minho_appears.xml 등
- 캐릭터 간 상호작용 디테일 추가

### Phase 3: 최적화 및 배포 준비 (3주차)
**목표**: 상용 출시 가능한 완성품 제작

#### 3.1 성능 최적화 (2일)
- 메모리 사용량 최적화
- 로딩 시간 단축
- 모바일 대응 준비

#### 3.2 사용자 테스트 (2일)
- 베타 테스터 모집
- 피드백 수집 및 반영
- 버그 수정 및 밸런스 조정

#### 3.3 배포 패키지 준비 (3일)
- Windows/Linux/Mac 빌드
- Steam 스토어 페이지 준비
- itch.io 업로드 및 마케팅 자료

---

## 💰 예상 비용 및 리소스

### 필수 비용 (최소 예산)
```
캐릭터 스프라이트 (15개):     $150-300 (외주) 또는 무료 (직접 제작)
배경 이미지 (8개):           $80-160 (외주) 또는 무료 (AI/무료 소스)
BGM (6곡):                  $120-300 (구매) 또는 무료 (Creative Commons)
SFX (9개):                  $30-60 (구매) 또는 무료 (Freesound)
Steam 등록비:               $100 (1회)

총 예상 비용:               $480-920 (외주 시) 또는 $100-200 (DIY)
```

### 추천 도구 및 서비스
**이미지 제작**:
- AI 생성: Stable Diffusion (무료), Midjourney ($10/월)
- 캐릭터: Picrew (무료), VRoid Studio (무료)
- 편집: GIMP (무료), Photoshop ($20/월)

**오디오 제작**:
- 무료: Freesound, YouTube Audio Library, OpenMusicArchive
- 유료: Artlist ($16/월), Epidemic Sound ($15/월)
- AI 생성: AIVA (무료), Soundraw ($17/월)

**게임 배포**:
- Steam: $100 등록비, 30% 수수료
- itch.io: 무료, 선택적 수수료 (0-10%)

---

## 🛠️ 실행 체크리스트

### Week 1 체크리스트
- [ ] Godot 프로젝트 열기 및 Episode 2 테스트
- [ ] 캐릭터 스프라이트 15개 제작/수집
- [ ] 배경 이미지 8개 제작/수집  
- [ ] 기본 UI 요소 디자인
- [ ] 첫 번째 플레이어블 빌드 완성

### Week 2 체크리스트  
- [ ] BGM 6곡 + SFX 9개 추가
- [ ] Episode 3, 5 XML 변환
- [ ] 추가 대화 씬 구현
- [ ] 음향 효과 연동 테스트
- [ ] 전체 시나리오 플레이테스트

### Week 3 체크리스트
- [ ] 성능 최적화 완료
- [ ] 베타 테스트 진행
- [ ] 버그 수정 및 밸런스 조정
- [ ] Steam/itch.io 배포 준비
- [ ] 마케팅 자료 제작

---

## 📈 성공 지표 (KPI)

### 기능적 완성도 목표
- [ ] **플레이타임**: Episode 2 기준 30분 이상
- [ ] **선택지 분기**: 모든 루트 정상 작동
- [ ] **미니게임 연동**: 오류 없는 호출/완료 시스템
- [ ] **저장/불러오기**: 완전한 세이브 시스템

### 품질 지표 목표
- [ ] **안정성**: 1시간 연속 플레이 시 크래시 0건
- [ ] **성능**: 60FPS 안정적 유지
- [ ] **메모리**: 512MB 이하 사용량
- [ ] **로딩**: 씬 전환 3초 이내

### 사용자 만족도
- [ ] **베타 테스터 평가**: 4.0/5.0 이상
- [ ] **스토리 만족도**: 긍정 피드백 80% 이상
- [ ] **기술적 안정성**: 버그 신고 5% 이하
- [ ] **재플레이 의도**: 60% 이상 의향

---

## 🚀 장기 확장 계획 (3개월 이후)

### 콘텐츠 확장
- Episode 1, 4 완전 구현
- Episode 6-10 추가 제작
- 추가 미니게임 개발 (총 60개+)
- 멀티 엔딩 시스템 확장

### 기술적 개선
- 음성 더빙 시스템 추가
- 애니메이션 효과 강화
- 모바일 플랫폼 포팅
- 다국어 번역 (영어, 일본어)

### 비즈니스 확장  
- Steam 출시 및 마케팅
- 시리즈 브랜딩 강화
- 팬아트/팬픽 커뮤니티 구축
- 굿즈 및 OST 판매

---

## 📞 즉시 실행 가능한 첫 단계

### 🎮 오늘 바로 할 수 있는 일
1. **Godot 열고 게임 테스트**: Episode 2 시나리오 플레이
2. **AI 이미지 생성**: Stable Diffusion으로 캐릭터 스프라이트 시작
3. **무료 배경 수집**: Unsplash에서 학교/카페 배경 다운로드
4. **오디오 탐색**: Freesound에서 효과음 찾기

### 📅 이번 주 목표
- 기본 에셋으로 Episode 2 완전 플레이 가능한 상태 완성
- 첫 번째 데모 버전 지인들에게 테스트 요청

**이제 당신의 비주얼 노벨이 실제 게임으로 완성될 시간입니다! 🌟**

---

*로드맵 작성일: 2024년 11월 28일*  
*예상 완성일: 2025년 1월 15일 (7주 후)*  
*최종 목표: Steam 상용 출시 준비 완료*
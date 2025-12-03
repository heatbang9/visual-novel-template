# Mystery Novel: 안개 속 오케스트라 (Fogbound Orchestra)

사운드와 기억을 소재로 한 고딕 미스터리 비주얼 노벨. 밤마다 안개에 잠기는 해안 도시 **루멘헤이븐**을 무대로, 실종된 작곡가의 마지막 악보가 불러온 연쇄 사건을 따라간다.

## 핵심 컨셉
- **소리 기반 단서**: 배경 사운드와 악보가 주요 단서로 작동
- **기억 왜곡**: 플레이어 선택에 따라 장면의 기억이 변형되어 재생
- **도시 전설**: 30년 전 오케스트라 화재 사건과 현재 실종 사건이 교차

## 파일 구조(제안)
```
mystery_novel/projects/fogbound_orchestra/
├── README.md
├── docs/
│   ├── project_overview.md
│   ├── structure.md
│   └── novel_script.md
├── characters/
│   ├── protagonist.md
│   ├── supporting_characters.md
│   └── antagonists.md
├── assets/
│   └── README.md
└── resources/
    └── README.md
```

## LLM → XML 변환 가이드 태그
- `<logline>`, `<theme>`, `<setting>`, `<cast>`: 메타 정보
- `<mbti>`: 캐릭터 MBTI, 성향 태그 (예: `INTJ|음악천재|청각과민`)
- `<beats>`: 챕터별 플롯 비트 (각 비트에 `@branch` 라벨)
- `<scene>`: 장면 단위 상세 텍스트, `id`와 `next` 속성으로 분기 힌트
- `<choice>`: 선택지 텍스트와 요구 능력치 (`courage`, `empathy`, `logic`, `perception`)
- `<memory_state>`: 기억 왜곡 상태 라벨 (`clear`, `hazy`, `echoed`, `false`)

## 진행 능력치(예시)
- `courage`: 위험한 장소 조사
- `empathy`: 인물 설득, 트라우마 케어
- `logic`: 단서 추론, 타임라인 재구성
- `perception`: 청음, 미세한 소리 구분

## 엔딩 구성
- True Ending: 연소된 악보의 숨겨진 코드 해독, 도시 전설 해소
- Bittersweet: 진실 발견하지만 희생 수반
- Cover-up: 권력층의 덮어쓰기, 진실 잠김
- False Memory: 조작된 기억에 굴복

# Mystery Novel: 시계탑의 메아리 (Clocktower Echoes)

안개와 시간 왜곡을 품은 해안 언덕의 오래된 시계탑을 무대로, 주인공이 과거와 현재를 잇는 "메아리 우편"을 통해 잊힌 죄와 용서를 추적하는 미스터리 비주얼 노벨.

## 핵심 컨셉
- **시간 지연 우편**: 시계탑에서 보내는 편지가 과거/미래로 전달
- **청각/촉각 단서**: 시계태엽 소리, 종 울림 패턴으로 퍼즐 진행
- **기억 조각 모드**: 장면이 `clarity/hum/echo/distort` 상태로 변조

## 파일 구조(제안)
```
mystery_novel/projects/clocktower_echoes/
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

## LLM → XML 태그 힌트
- `<logline>`, `<theme>`, `<setting>`, `<cast>`: 메타 데이터
- `<mbti>`: 캐릭터 성향/MBTI/감각 태그
- `<memory_state>`: `clarity`, `hum`, `echo`, `distort`, `fixed`
- `<scene id="" next="">` + `<choice>`: 분기 구조, 능력치 요구 `intuition, resolve, empathy, deduction`
- `<letter>`: 시간 우편 내용, `target_time` 속성으로 과거/미래 명시

## 능력치(예시)
- `intuition`: 직감, 시간 겹침 감지
- `resolve`: 위험 대처, 고소공포 극복
- `empathy`: 편지 수신자 설득/위로
- `deduction`: 종 패턴, 태엽 소리 해독

## 엔딩 키워드
- True: 죄의 인정 + 용서 편지 전달 성공
- Paradox: 잘못된 시간대에 편지 전달, 모순
- Silence: 종이 멈추고 진실이 묻힘
- Echo: 끝없는 반복, 왜곡된 기억에 고립

# 스토리 구조 & 비트맵

<beats>
1. 프롤로그 — `@branch:intro` : 안개 낀 새벽, 주인공이 헤이븐 홀에서 잔향을 녹음하며 숨겨진 멜로디를 듣는다.
2. 막1 — `@branch:call` : 실종 공지와 함께 악보 조각 도착. 도시 전설 소개.
3. 막2 — `@branch:investigation` : 항만·음향실·콘서트홀 폐허 조사. 세 갈래 조사 루트.
4. 막3 — `@branch:reverb` : 30년 전 화재 녹음 발견, 기억 왜곡 상태 진입(`hazy`).
5. 막4 — `@branch:confront` : 재단 이사와 대치, 경찰 커버업 시도(`cover_path`).
6. 막5 — `@branch:restoration` : 마지막 연주 시퀀스, 숨겨진 코드 해독(`truth_path`).
7. 에필로그 — `@branch:endings` : 엔딩 4종 (True/Bittersweet/Cover-up/False Memory)
</beats>

## 분기 설계
- **탐사 루트**: 항만 → 관리인 루트 / 녹음실 → 기자 루트 / 홀 지하 → 위험 루트
- **기억 상태**: clear ↔ hazy ↔ echoed ↔ false ↔ restored (선택지로 이동)
- **엔딩 트리거**
  - `evidence_score >= 8` & `logic >= 4` → True
  - `evidence_score 5-7` & `empathy >= 4` → Bittersweet
  - `cover_influence >= 3` → Cover-up
  - `memory_state == false` → False Memory

## 장면 ID 네이밍
- `prologue_echo`, `dock_signal`, `archive_break`, `hall_fireflash`, `rooftop_recital`, `final_resonance`

## 반복 연출
- 선택 실패 시 동일 장면을 다른 기억 상태로 재방문 (텍스트 색/효과만 변조)
- 소리 단서 반복: 금속 긁힘 → 현악 잔향 → 멜로디 코드(숫자): 3-1-4-1-5-9

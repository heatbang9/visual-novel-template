# 스토리 구조 & 비트

<beats>
1. 프롤로그 — `bell_one` : 자정 첫 종, 익명 편지 도착
2. 막1 — `letter_past` : 20년 전 익사 사건 언급, 편지 해독
3. 막2 — `investigate_tower` : 시계탑 내부/외벽/지하실 3갈래 루트
4. 막3 — `echo_confront` : 과거 발신자 단서, 경찰 압박, 기억 왜곡 상승
5. 막4 — `bridge_night` : 폭풍우 속 절벽 다리 대치, 메아리 편지 교환
6. 에필로그 — `resolution` : 엔딩 라우터 (True/Paradox/Silence/Echo)
</beats>

## 분기 키
- 루트: 외벽 클라임(해진) / 문서탐색(미연) / 사제 대화(도리안)
- 기억: clarity↔hum↔echo↔distort↔fixed 전환, 선택마다 `<memory_state>` 변경
- 엔딩 조건
  - True: deduction 4+, empathy 4+, evidence 8+, memory=fixed
  - Paradox: letter 오배송(과거/미래 mismatch)
  - Silence: resolve 실패로 종 멈춤
  - Echo: memory=distort 유지

## 장면 ID 예시
- `bell_one`, `rusted_mail`, `tower_wall`, `tower_archive`, `tower_crypt`, `bridge_confront`, `final_bell`

## 반복 장치
- 종소리 패턴 3-5-3-1-2가 반복 등장 → 잘못 입력 시 distort로 이동
- 편지 내용이 각 루프마다 미세히 달라짐 → LLM이 변수 치환 활용

# 시계탑의 메아리 — 시나리오 드래프트 (LLM 태그 포함)

<theme>시간 왜곡 · 죄와 용서 · 침묵과 고백</theme>
<setting>카데나 해안, 늦여름 5일 밤</setting>

## Act 0: 프롤로그 — `bell_one`
<memory_state>clarity</memory_state>
<scene id="bell_one" next="rusted_mail|tower_wall">
자정, 시계탑 종이 한 번 울린다. 안개에 젖은 공기 사이로 종소리가 바다를 스친다. 시안은 탑 아래에서 손끝으로 벽돌을 만진다. 벽돌 틈에서 눅눅한 봉투가 떨어진다.

<letter target_time="past">나는 그날 문을 닫은 사람을 알고 있다. 종이 멈추기 전에 용서를 청해야 한다. — H</letter>

시안은 손끝을 봉투에 대자 20년 전 파도 소리와 아이의 비명 잔향을 듣는다. 고소공포가 목을 조이지만, 탑 위로 올라가야 한다는 예감이 스친다.
</scene>

<choice id="climb_now" text="지금 바로 외벽을 오른다" requires="resolve>=3" effects="memory_state=hum" next="tower_wall" />
<choice id="analyze_letter" text="편지부터 분석한다" requires="deduction>=3" effects="evidence+1" next="rusted_mail" />

## Act 1: 첫 편지 — `rusted_mail`
<memory_state>clarity</memory_state>
<scene id="rusted_mail" next="tower_archive|tower_wall">
류미연이 구 우체국 열쇠를 가져온다. 내부는 먼지와 곰팡이 냄새로 가득하다. 오래된 우편 로그에서 20년 전 8월에 멈춘 기록을 발견한다. 발신인 이름은 모두 "H"로 덧칠되어 있다.

미연: "여기, 이 편지만 잔향이 남아. 종 울림과 동시에 찍힌 도장." 시안은 도장을 만지며 잔향을 듣는다. "도장은 자정 12:00, 종 바로 전."
</scene>

<choice id="log_copy" text="로그를 복사해두고 탑으로" requires="deduction>=3" effects="evidence+1" next="tower_wall" />
<choice id="stay_archive" text="기록 더 뒤진다" requires="intuition>=3" effects="memory_state=hum" next="tower_archive" />

## Act 2: 조사 루트 — 시계탑/기록/지하실

### 루트 A: 외벽 클라임 — `tower_wall`
<scene id="tower_wall" next="tower_bell|tower_crypt">
강해진이 로프를 던진다. 바람이 로프를 때린다. 시안은 손끝으로 태엽 소리를 듣는다: 종은 이미 두 번 울릴 준비를 하고 있다.

<choice id="climb_with_haejin" text="해진과 함께 오른다" requires="resolve>=3" effects="memory_state=hum,danger+1" next="tower_bell" />
<choice id="send_drone" text="드론으로 상단 스캔" requires="intuition>=3" effects="evidence+1" next="tower_bell" />
<choice id="retreat_wall" text="고소공포로 내려간다" requires="empathy>=2" effects="memory_state=echo" next="tower_archive" />
</scene>

### 루트 B: 기록실 심화 — `tower_archive`
<scene id="tower_archive" next="tower_bell|tower_crypt">
미연이 오래된 필름을 영사기에 건다. 필름에는 소년이 시계탑 문을 닫는 장면이 흑백으로 찍혀 있다. 태엽을 잠그는 손이 비친다.

<choice id="identify_hand" text="손 모양 분석" requires="deduction>=4" effects="evidence+2" next="tower_bell" />
<choice id="soften_memory" text="시안의 촉각으로 추적" requires="intuition>=4" effects="memory_state=hum" next="tower_crypt" />
</scene>

### 루트 C: 지하실 — `tower_crypt`
<memory_state>hum</memory_state>
<scene id="tower_crypt" next="tower_bell|echo_hall">
지하실은 젖은 돌 냄새와 녹슨 태엽 부품으로 가득하다. 도리안 사제가 촛불을 든다. "이곳은 종의 심장이다." 태엽을 만지는 순간, 시안은 익사 사고의 잔향을 더 뚜렷이 듣는다.

<choice id="confess_to_dorian" text="도리안에게 편지 내용 공유" requires="empathy>=3" effects="memory_state=echo" next="tower_bell" />
<choice id="hide_from_dorian" text="내용 숨기고 태엽만 본다" requires="deduction>=3" effects="danger+1" next="echo_hall" />
</scene>

## Act 3: 종소리와 대치 — `tower_bell` / `echo_hall`
<memory_state>echo</memory_state>
<scene id="tower_bell" next="bridge_confront|police_block">
세 번째 종이 울린다. 금속 잔향이 길게 늘어진다. 한소정 경찰이 올라와 테이프를 친다. "불법 침입 중지. 편지 제출." 해진이 드론을 숨기려 하지만, 한소정이 손을 뻗는다.

<choice id="argue_police" text="법적 근거 요구" requires="deduction>=3,empathy>=3" effects="cover_influence-1,evidence+1" next="police_block" />
<choice id="distract_with_bell" text="종을 일부러 울려 혼란" requires="resolve>=4" effects="danger+1,memory_state=distort" next="bridge_confront" />
<choice id="hand_over_letter" text="편지 일부만 건넨다" requires="empathy>=2" effects="cover_influence+1" next="bridge_confront" />
</scene>

<scene id="echo_hall" next="bridge_confront">
지하실 회랑에서 태엽이 멈칫거린다. 정무열이 나타나 태엽을 뽑으려 한다. "이 종이 울리지 않으면, 더는 아무도 죽지 않아." 시안은 그의 손을 막는다. 잔향이 왜곡되며 익사 순간이 반복 재생된다.

<choice id="stop_muyeol" text="태엽을 지킨다" requires="resolve>=4" effects="danger+2,memory_state=distort" next="bridge_confront" />
<choice id="let_him" text="잠시 멈추게 허락" requires="intuition>=3" effects="evidence-1,memory_state=echo" next="bridge_confront" />
</scene>

## Act 4: 절벽 다리 대치 — `bridge_confront`
<memory_state>distort</memory_state>
<scene id="bridge_confront" next="final_bell">
폭풍우 속 절벽 다리. 아래로 파도가 치고, 안개가 눈을 찌른다. 도리안이 봉투를 들고 있다. "이 편지는 미래로 가야 해. 그렇지 않으면 종이 멈춘다."

정무열: "그 편지는 과거로 보내야 해. 동생은 진실을 들어야 해." 한소정이 무전을 받는다. "본청에서 철수 명령." 갈등이 삼중으로 겹친다.

시안은 두 봉투를 쥔다. 하나는 과거로, 하나는 미래로. 손끝에 잔향이 갈라진다.
</scene>

<choice id="send_past" text="과거로 보내 죄를 직면" requires="empathy>=4" effects="evidence+2,memory_state=fixed" next="final_bell" />
<choice id="send_future" text="미래로 보내 반복 방지" requires="deduction>=4" effects="cover_influence-1,memory_state=echo" next="final_bell" />
<choice id="split_letters" text="봉투를 나눠 두 시대로" requires="intuition>=4" effects="paradox+2,memory_state=distort" next="final_bell" />
<choice id="drop_letters" text="편지를 버리고 종을 멈춘다" requires="resolve>=3" effects="silence+2,memory_state=distort" next="final_bell" />

## Act 5: 마지막 종 — `final_bell`
<scene id="final_bell" next="ending_router">
네 번째, 다섯 번째 종이 이어서 울린다. 시안은 손끝으로 태엽을 조인다. 잔향이 한 줄기로 합쳐지며, 20년 전 익사 순간이 완전한 영상처럼 떠오른다.

그날 시계탑 문을 닫은 사람은 도리안의 동생 H였고, 정무열이 밖에서 문을 잠가버렸다. 한소정의 상관이 이를 은폐했다. 모든 조각이 맞물린다. 종은 마지막 진동을 남기며 멈춘다.
</scene>

## 엔딩 라우터
<scene id="ending_router" next="ending_true|ending_paradox|ending_silence|ending_echo">
<choice id="ending_true_gate" text="evidence 8+, empathy 4+, memory fixed" requires="evidence>=8,empathy>=4,memory_state==fixed" next="ending_true" />
<choice id="ending_paradox_gate" text="paradox 2+" requires="paradox>=2" next="ending_paradox" />
<choice id="ending_silence_gate" text="silence 2+" requires="silence>=2" next="ending_silence" />
<choice id="ending_echo_gate" text="memory distort" requires="memory_state==distort" next="ending_echo" />
</scene>

### True Ending — `ending_true`
<scene id="ending_true">
과거로 보낸 편지가 도리안 동생의 일기를 바꾼다. 정무열은 죄를 인정하고 종을 다시 울린다. 한소정은 진술서를 제출한다. 시안은 고소공포를 딛고 시계탑 꼭대기에 올라 종을 울린다. 바다 위로 금빛 잔향이 번진다.
</scene>

### Paradox Ending — `ending_paradox`
<scene id="ending_paradox">
편지가 두 시대로 나뉘어 서로 모순된 기억을 만든다. 시안은 매 자정 다른 기억으로 깨어난다. 종은 영원히 3-5-3-1-2 사이에서 멈춘다.
</scene>

### Silence Ending — `ending_silence`
<scene id="ending_silence">
편지가 버려지고 종이 멈춘다. 카데나에는 고요가 찾아오지만, 익사와 실종의 진실은 영원히 묻힌다. 시안은 촉각 잔향을 잃고, 밤마다 바다의 침묵만 듣는다.
</scene>

### Echo Ending — `ending_echo`
<scene id="ending_echo">
왜곡된 기억이 고정된다. 시안은 자신이 문을 닫았다고 믿으며 죄책감에 갇힌다. 종은 울릴 때마다 같은 장면을 반복 재생한다. 플레이어는 루프를 탈출하기 전까지 같은 선택을 반복하게 된다.
</scene>

---

## 샘플 대사
- 시안: "태엽이 숨을 쉰다. 금속의 호흡 속에서 목소리가 겹친다."
- 해진: "드론이 보여준 건, 우리보다 높은 고소공포야. 난 그래도 간다."
- 미연: "기록은 변조될 수 있어. 하지만 잔향은 거짓말을 못 해."
- 도리안: "용서는 누구의 시간에 있어야 하나? 보내는 자의 시간인가, 받는 자의 시간인가."
- 한소정: "실적보다 중요한 게 있다고? 그럼 내 상관에게 말해봐."
- 정무열: "종이 멈추면 시간이 멈춰. 그게 내가 원하는 답이다."

## LLM XML 변환 메모
- `<scene>`/`<choice>` 그대로 XML 변환 가능, `next`로 분기 연결
- `<letter>`는 별도 데이터/아이템으로 매핑, `target_time` 필수 속성
- 기억 상태를 전역 변수로 두고 장면 진입 시 업데이트
- 검증 변수: evidence, danger, cover_influence, paradox, silence, memory_state, intuition, resolve, empathy, deduction

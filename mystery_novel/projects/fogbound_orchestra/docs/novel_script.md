# 안개 속 오케스트라 — 풀 시나리오 드래프트 (LLM용 태그 포함)

<theme>고딕 미스터리 · 기억 왜곡 · 음악과 폭력의 경계</theme>
<setting>루멘헤이븐, 장마 후 7일간 밤</setting>

## Act 0: 프롤로그 — `prologue_echo`
<memory_state>clear</memory_state>
<scene id="prologue_echo" next="dock_signal|archive_break">
안개가 유리창을 문지르듯 스치는 새벽, 도은은 폐허가 된 헤이븐 홀 무대 위에 카세트를 놓고 잔향을 녹음한다. 전기가 끊긴 홀의 공기는 축축하고 차갑다. 멀리서 희미한 현악 음 한 줄이 녹음기에 걸린다.

도은의 심장은 무대 조명만큼 밝게 뛰지 않는다. 대신 어둠 속에서 파형을 읽는다. 3-1-4-1-5-9. 익숙한 숫자열이 되풀이된다.

녹음기가 딸깍이며 멈추는 순간, 누군가 객석 뒤에서 떨어뜨린 금속 소리가 울린다. 도은은 돌아보지만 안개만 있다.
</scene>

## Act 1: 호출 — `call_notice`
<memory_state>clear</memory_state>
<scene id="call_notice" next="dock_signal">
학교에 붙은 실종 공지. 작곡가 이시안, 3일 전 실종. 익명 발신의 봉투가 도은 책상에 놓인다. 봉투 안에는 반쯤 그을린 악보 조각과 QR 코드. QR을 스캔하자 30년 전 오케스트라 화재 기사와 함께 "소리를 따라와"라는 메시지가 뜬다.

장리오가 등교길에 뛰어와 악보 조각을 보고 말한다. "이거, 나 어릴 때 들은 멜로디랑 같아."

백유진은 기사를 확대하며 말한다. "화재, 30년 전. 교향악단이 전소. 시체는 일부만 발견." 기자 특유의 건조한 어조가 교실 공기를 자른다.
</scene>

<choice id="accept_call" text="악보를 추적한다" requires="perception>=4" effects="logic+1,evidence+1" next="dock_signal" />
<choice id="ignore_call" text="무시하려 하지만 멜로디가 머릿속을 떠나지 않는다" requires="empathy>=3" effects="memory_state=hazy" next="dock_signal" />

## Act 2: 조사 — 삼중 루트

### 루트 A: 항만 창고 — `dock_signal`
<scene id="dock_signal" next="archive_break|hall_subway">
항만 창고에서 금속 긁힘과 함께 낮은 호른 소리가 섞인 잔향이 들린다. 리오가 휴대용 건반으로 따라 치자, 벽 너머에서 응답하듯 같은 코드가 돌아온다.

노지혁 관리인이 등장한다. "여긴 출입 금지야." 그의 눈빛은 안개색이다. 도은은 녹음기를 흔들며 보여준다. "이 소리, 홀에서 이어졌어요."

<choice id="persuade_keeper" text="설득: 화재 당시 기억을 묻는다" requires="empathy>=3" effects="evidence+1" next="keeper_talk" />
<choice id="sneak_past" text="잠입: 창고 뒤편 통로로 숨어든다" requires="courage>=3" effects="danger+1,memory_state=hazy" next="hall_subway" />
</scene>

<scene id="keeper_talk" next="archive_break">
노지혁은 한숨을 내쉰다. "그날, 천장에서 떨어진 불씨보다 무서웠던 건… 누군가 문을 잠갔다는 거야." 그는 녹슨 열쇠를 준다. "홀 지하 출입구."
</scene>

### 루트 B: 학교 음향실 — `archive_break`
<scene id="archive_break" next="hall_fireflash|hall_subway">
음향실 저장고, 도은은 오래된 DAT 테이프를 발견한다. 라벨: "Haven Hall Rehearsal 1994". 재생하자 관악기의 리허설, 갑작스러운 화재 경보, 그리고 거친 숨이 녹음되어 있다.

테이프 끝에서, 한 소녀의 목소리가 낮게 속삭인다. "문을… 잠갔어…" 노이즈가 섞이며 멜로디 코드가 반복된다.

<choice id="analyze_tape" text="스펙트럼 분석" requires="logic>=3" effects="evidence+2" next="hall_fireflash" />
<choice id="share_with_yujin" text="유진과 공유" requires="empathy>=3" effects="teamwork+1" next="hall_fireflash" />
</scene>

### 루트 C: 홀 지하 — `hall_subway`
<scene id="hall_subway" next="hall_fireflash">
지하 통로. 물이 고여 있고, 철제 사다리는 녹슬었다. 도은은 손전등으로 벽에 새겨진 숫자를 본다: 3-1-4-1-5-9.

갑자기 스피커에서 잡음이 터지고, 전기가 들어온 듯 무대 조명 잔상이 켜진다. 도은은 숨을 삼키며 트라우마를 떠올린다.

<choice id="push_forward" text="조명 아래로 나아간다" requires="courage>=4" effects="memory_state=echoed" next="hall_fireflash" />
<choice id="retreat" text="철수하고 다시 계획" requires="logic>=3" effects="danger-1" next="archive_break" />
</scene>

## Act 3: 잔향 — `hall_fireflash`
<memory_state>hazy</memory_state>
<scene id="hall_fireflash" next="rooftop_recital|cop_barrier">
콘서트홀 메인 무대. 관객석은 안개 속 석고상처럼 보인다. 한 순간, 30년 전의 화염이 환영처럼 번쩍이며 무대 장치를 태운다.

도은은 환청을 듣는다. "다들 탈출했어?" "문이… 안 열려!" 동시에, 현재의 경찰 라인이 둘러쳐지며 이문호 형사가 나타난다. "학생들은 여기 오면 안 돼. 사건 수사 중이야."

백유진이 형사를 바라본다. "이모부, 화재 기록 공개하세요." 갈등이 일어난다.

<choice id="challenge_cop" text="공개 요구" requires="empathy>=3,logic>=3" effects="evidence+1,cover_influence-1" next="cop_barrier" />
<choice id="secret_pass" text="관리인이 준 열쇠로 비밀 통로" requires="perception>=4" effects="danger+1" next="rooftop_recital" />
</scene>

<scene id="cop_barrier" next="rooftop_recital|cover_path">
이문호는 기록을 일부 공개하지만, 가장 중요한 부분은 검열된 상태다. 유진의 표정이 굳는다. "덮으라는 거죠?"

<choice id="accept_partial" text="부분 정보로도 간다" requires="logic>=3" effects="evidence+1" next="rooftop_recital" />
<choice id="push_cover" text="커버업에 협조" requires="empathy>=2" effects="cover_influence+2,memory_state=false" next="cover_path" />
</scene>

## Act 4: 대치 — `rooftop_recital` & `cover_path`

### 진실 루트: 옥상 리허설 — `rooftop_recital`
<memory_state>echoed</memory_state>
<scene id="rooftop_recital" next="final_resonance">
헤이븐 홀 옥상. 밤바람과 안개가 현악처럼 떤다. 리오가 악보 조각을 이어붙여 연주한다. 도은은 녹음기를 켜고, 잔향 속에 숨겨진 숫자 코드를 소리로 변환한다.

코드가 완성되는 순간, 30년 전 화재 당시 닫혀 있던 문 위치에 새로운 문이 떠오른다. 노지혁이 가리킨다. "저기가… 잠겼던 곳." 도은은 공포를 억누르며 다가간다.
</scene>

### 커버 루트: 재단 사무실 — `cover_path`
<memory_state>false</memory_state>
<scene id="cover_path" next="final_resonance">
서은채의 사무실. 그녀는 계약서를 내민다. "모든 자료는 재단에 넘기고, 학생들은 입 다물어요." 이문호가 곁에서 무표정하게 서 있다.

<choice id="sign_contract" text="서명한다" requires="empathy>=2" effects="cover_influence+3,memory_state=false" next="final_resonance" />
<choice id="refuse_contract" text="거부하고 증거를 들고 나온다" requires="courage>=4" effects="danger+2,evidence+2,memory_state=echoed" next="final_resonance" />
</scene>

## Act 5: 복원 — `final_resonance`
<memory_state>restored</memory_state>
<scene id="final_resonance" next="ending_selector">
무대 중앙, 도은은 헤드셋을 착용하고 마지막 연주를 재생한다. 악보의 빈 칸을 도은의 기억이 채운다. 숫자열이 멜로디로 변환되고, 화재 당시 누군가 문을 잠근 순간의 금속음이 정확히 시간축에 위치한다.

"문을 잠근 건…" 도은의 눈이 커진다. 녹음된 목소리는 서은채의 어린 목소리와 일치한다. 재단의 덮개가 벗겨지고, 경찰 기록의 공백이 메워진다.

안개가 걷히듯, 무대 조명이 서서히 켜진다. 도은은 처음으로 무대 한가운데에 선다. 공포와 함께 깊은 호흡. "이 연주는, 기억을 복원합니다." 그녀는 트라우마를 삼키고 멜로디를 연주한다.
</scene>

## 엔딩 라우터
<scene id="ending_selector" next="ending_true|ending_bitter|ending_cover|ending_false">
<choice id="ending_true_gate" text="증거 8+, 용기 4+" requires="evidence>=8,courage>=4" next="ending_true" />
<choice id="ending_bitter_gate" text="증거 5-7, 공감 4+" requires="evidence>=5,evidence<=7,empathy>=4" next="ending_bitter" />
<choice id="ending_cover_gate" text="커버 영향 3+" requires="cover_influence>=3" next="ending_cover" />
<choice id="ending_false_gate" text="기억 상태 false" requires="memory_state==false" next="ending_false" />
</scene>

### True Ending — `ending_true`
<scene id="ending_true">
경찰은 재단 비리를 수사하기 시작하고, 헤이븐 홀은 기억을 위한 공연장으로 재개장한다. 도은은 무대 공포를 넘어 첫 공식 연주를 한다. 리오와 유진이 객석에서 손을 흔든다.

안개 속 금속음은 더 이상 위협이 아니다. 그것은 박수와 함께 잔향으로 변한다.
</scene>

### Bittersweet — `ending_bitter`
<scene id="ending_bitter">
진실은 밝혀지지만, 서은채는 해외로 도피하고, 이문호는 내부 고발자로 좌천된다. 도은은 무대 공포를 넘어 연주하지만, 멜로디의 마지막 마디는 화재로 잃은 목소리처럼 공허하게 남는다.
</scene>

### Cover-up — `ending_cover`
<scene id="ending_cover">
계약서에 서명한 대가로 재단은 장학금을 제공하고 사건은 잠든다. 도은은 트라우마를 극복하지 못한 채 음향 기록만 남긴다. 안개는 매년 같은 멜로디를 속삭이며 돌아온다.
</scene>

### False Memory — `ending_false`
<scene id="ending_false">
도은의 기억은 완전히 왜곡되어, 화재 당시의 희생자가 스스로 문을 잠갔다고 믿는다. 플레이어는 왜곡된 서사를 받아들이며, 안개 속 홀에서 끝없이 같은 멜로디를 반복해 듣는다.
</scene>

---

## 장면별 샘플 대사 (발췌)
- 도은 내면 독백: "금속음이 파형 위로 흘러내린다. 잔향이 기억을 긁어낸다."
- 리오: "이 코드, 숫자 말고도 숨겨진 게 있어. 3-1-4-1-5-9… 파이? 아니, 말하지 않는 이름."
- 유진: "기록은 거짓말을 못 해. 사람들이 거짓말을 할 뿐."
- 서은채: "예술은 고통 위에 서. 그걸 모르는 아이들이 진실을 감당할 수 있을까?"
- 이문호: "난 그때 명령을 따랐다. 지금은… 뭘 따르지?"

## LLM XML 변환 힌트
- 각 `<scene>`을 XML `<scene id="...">`로 매핑, `next`를 분기 연결에 사용
- `<choice>`는 `<choice text="..." requires="" effects="" next=""/>`로 직변환 가능
- `<memory_state>`를 루트 변수로 선언 후 scene마다 set/transition
- 엔딩 조건을 검증기로 체킹: `evidence`, `cover_influence`, `memory_state`, `courage`, `empathy`, `logic`, `perception`

## 확장 아이디어
- 미니게임: 잡음 속 멜로디 찾기(스펙트럼 퍼즐)
- 반복 루프: 실패 시 기억 상태가 더 악화되어 다른 대사/연출 노출
- 음향 UI: 특정 소리를 길게 누르면 숨겨진 텍스트 출력(LLM이 비밀 대사 삽입)

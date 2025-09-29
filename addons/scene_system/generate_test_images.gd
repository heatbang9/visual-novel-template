@tool
extends EditorScript

func _run():
    # 교실 배경 이미지 생성
    var classroom = Image.create(1280, 720, false, Image.FORMAT_RGB8)
    classroom.fill(Color(0.8, 0.8, 0.9)) # 연한 파란색
    for i in range(0, 1280, 50):
        classroom.fill_rect(Rect2i(i, 0, 2, 720), Color(0.7, 0.7, 0.8))
    for i in range(0, 720, 50):
        classroom.fill_rect(Rect2i(0, i, 1280, 2), Color(0.7, 0.7, 0.8))
    classroom.save_png("res://assets/backgrounds/classroom.png")

    # 철수 캐릭터 이미지 생성
    var chulsoo = Image.create(300, 600, false, Image.FORMAT_RGBA8)
    chulsoo.fill(Color(0, 0, 0, 0))
    # 얼굴
    chulsoo.fill_rect(Rect2i(100, 50, 100, 100), Color(1, 0.8, 0.6, 1))
    # 몸통
    chulsoo.fill_rect(Rect2i(75, 150, 150, 400), Color(0.2, 0.3, 0.8, 1))
    chulsoo.save_png("res://assets/characters/chulsoo/normal.png")

    # 영희 캐릭터 이미지 생성
    var younghee = Image.create(300, 600, false, Image.FORMAT_RGBA8)
    younghee.fill(Color(0, 0, 0, 0))
    # 얼굴
    younghee.fill_rect(Rect2i(100, 50, 100, 100), Color(1, 0.9, 0.7, 1))
    # 몸통
    younghee.fill_rect(Rect2i(75, 150, 150, 400), Color(0.8, 0.2, 0.3, 1))
    younghee.save_png("res://assets/characters/younghee/normal.png")

    print("테스트 이미지 생성 완료!")
extends Node

# 테스트 유틸리티
# 테스트 헬퍼 함수 및 공통 기능 제공

# XML 파일 생성 및 검증
static func create_test_xml(file_path: String, content: String) -> void:
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        file.store_string(content)
    else:
        push_error("테스트 XML 파일을 생성할 수 없습니다: " + file_path)

# XML 파일 삭제
static func cleanup_test_xml(file_path: String) -> void:
    if FileAccess.file_exists(file_path):
        DirAccess.remove_absolute(file_path)

# 더미 캐릭터 이미지 생성
static func create_dummy_character_image(file_path: String, size: Vector2 = Vector2(200, 400)) -> void:
    var image = Image.new()
    image.create(int(size.x), int(size.y), false, Image.FORMAT_RGB8)
    image.fill(Color(1, 1, 1))
    
    # 기본 윤곽 그리기
    for x in range(int(size.x)):
        for y in range(int(size.y)):
            if (x < 2 or x > size.x - 3 or y < 2 or y > size.y - 3):
                image.set_pixel(x, y, Color(0, 0, 0))
    
    image.save_png(file_path)

# 더미 배경 이미지 생성
static func create_dummy_background_image(file_path: String, size: Vector2 = Vector2(1280, 720)) -> void:
    var image = Image.new()
    image.create(int(size.x), int(size.y), false, Image.FORMAT_RGB8)
    
    # 그라데이션 배경
    for y in range(int(size.y)):
        var t = float(y) / size.y
        var color = Color(0.5 + 0.5 * t, 0.7 - 0.3 * t, 1.0 - 0.5 * t)
        for x in range(int(size.x)):
            image.set_pixel(x, y, color)
    
    image.save_png(file_path)

# 더미 오디오 파일 생성
static func create_dummy_audio_file(file_path: String, duration: float = 1.0) -> void:
    # 간단한 WAV 파일 헤더 생성
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not file:
        push_error("오디오 파일을 생성할 수 없습니다: " + file_path)
        return
    
    var sample_rate = 44100
    var bits_per_sample = 16
    var channels = 1
    var samples = int(duration * sample_rate)
    
    # WAV 파일 헤더
    file.store_buffer("RIFF".to_ascii_buffer())  # ChunkID
    file.store_32(36 + samples * 2)  # ChunkSize
    file.store_buffer("WAVE".to_ascii_buffer())  # Format
    file.store_buffer("fmt ".to_ascii_buffer())  # Subchunk1ID
    file.store_32(16)  # Subchunk1Size
    file.store_16(1)   # AudioFormat (PCM)
    file.store_16(channels)  # NumChannels
    file.store_32(sample_rate)  # SampleRate
    file.store_32(sample_rate * channels * bits_per_sample / 8)  # ByteRate
    file.store_16(channels * bits_per_sample / 8)  # BlockAlign
    file.store_16(bits_per_sample)  # BitsPerSample
    file.store_buffer("data".to_ascii_buffer())  # Subchunk2ID
    file.store_32(samples * 2)  # Subchunk2Size
    
    # 사인파 데이터 생성
    for i in range(samples):
        var t = float(i) / sample_rate
        var value = int(32767.0 * sin(2.0 * PI * 440.0 * t))  # 440Hz 사인파
        file.store_16(value)

# 시간 지연 시뮬레이션
static func wait_for_seconds(seconds: float) -> void:
    var timer = Timer.new()
    timer.one_shot = true
    timer.wait_time = seconds
    timer.timeout.connect(timer.queue_free)
    timer.start()

# 비동기 작업 대기
static func wait_for_signal(object: Object, signal_name: String, timeout: float = 5.0) -> bool:
    var timer = Timer.new()
    timer.one_shot = true
    timer.wait_time = timeout
    
    var timeout_reached = false
    var signal_received = false
    
    timer.timeout.connect(func():
        timeout_reached = true
    )
    
    object.connect(signal_name, func():
        signal_received = true
    )
    
    while not timeout_reached and not signal_received:
        await Engine.get_main_loop().process_frame
    
    timer.queue_free()
    return signal_received

# 메모리 사용량 측정
static func get_memory_usage() -> int:
    return OS.get_static_memory_usage()

# 성능 측정
static func measure_performance(function: Callable) -> float:
    var start_time = Time.get_ticks_usec()
    function.call()
    var end_time = Time.get_ticks_usec()
    return (end_time - start_time) / 1000000.0  # 초 단위로 변환

# 리소스 정리
static func cleanup_resources(paths: Array) -> void:
    for path in paths:
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(path)
        elif DirAccess.dir_exists_absolute(path):
            DirAccess.remove_absolute(path)
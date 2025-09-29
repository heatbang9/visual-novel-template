extends GutTest

# 배경 컨트롤러 단위 테스트

var background_controller: Node
var test_background: String = "res://test/resources/test_background.png"

func before_all():
    # 테스트 리소스 생성
    TestUtils.create_dummy_background_image(test_background)

func after_all():
    # 테스트 리소스 정리
    TestUtils.cleanup_resources([test_background])

func before_each():
    background_controller = preload("res://scripts/background/background_controller.gd").new()
    add_child_autofree(background_controller)
    await get_tree().process_frame

func test_background_initialization():
    assert_not_null(background_controller, "배경 컨트롤러가 생성되어야 함")
    assert_eq(background_controller.current_weather, 0, "초기 날씨는 맑음이어야 함")
    assert_eq(background_controller.current_time, 0, "초기 시간은 낮이어야 함")

func test_background_change():
    # 배경 변경 시그널 감지
    watch_signals(background_controller)
    
    # 페이드 전환
    background_controller.change_background(test_background, "fade", 0.1)
    await wait_seconds(0.2)
    assert_signal_emitted(background_controller, "transition_completed")
    
    # 크로스페이드 전환
    background_controller.change_background(test_background, "crossfade", 0.1)
    await wait_seconds(0.2)
    assert_signal_emitted(background_controller, "transition_completed")
    
    # 즉시 전환
    background_controller.change_background(test_background, "instant")
    assert_signal_emitted(background_controller, "transition_completed")

func test_weather_effects():
    watch_signals(background_controller)
    
    # 비 효과
    background_controller.set_weather(1, 0.1)  # Weather.RAIN
    await wait_seconds(0.2)
    assert_signal_emitted(background_controller, "effect_started")
    assert_eq(background_controller.current_weather, 1, "날씨가 비로 변경되어야 함")
    
    # 눈 효과
    background_controller.set_weather(2, 0.1)  # Weather.SNOW
    await wait_seconds(0.2)
    assert_signal_emitted(background_controller, "effect_started")
    assert_eq(background_controller.current_weather, 2, "날씨가 눈으로 변경되어야 함")
    
    # 안개 효과
    background_controller.set_weather(3, 0.1)  # Weather.FOG
    await wait_seconds(0.2)
    assert_signal_emitted(background_controller, "effect_started")
    assert_eq(background_controller.current_weather, 3, "날씨가 안개로 변경되어야 함")

func test_time_of_day():
    watch_signals(background_controller)
    
    # 시간 변경 테스트
    for time in [1, 2, 3]:  # SUNSET, NIGHT, SUNRISE
        background_controller.set_time_of_day(time, 0.1)
        await wait_seconds(0.2)
        assert_eq(background_controller.current_time, time, 
            "시간이 올바르게 변경되어야 함: " + str(time))

func test_invalid_inputs():
    # 잘못된 전환 타입
    background_controller.change_background(test_background, "invalid_transition")
    assert_eq(background_controller.current_weather, 0, "잘못된 입력은 무시되어야 함")
    
    # 존재하지 않는 배경
    background_controller.change_background("invalid_path")
    assert_eq(background_controller.current_weather, 0, "잘못된 입력은 무시되어야 함")
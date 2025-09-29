extends Node

# XML에서 배경 효과 관련 태그를 파싱하고 처리하는 클래스

const WEATHER_MAPPING = {
    "clear": 0,  # Weather.CLEAR
    "rain": 1,   # Weather.RAIN
    "snow": 2,   # Weather.SNOW
    "fog": 3     # Weather.FOG
}

const TIME_MAPPING = {
    "day": 0,     # TimeOfDay.DAY
    "sunset": 1,  # TimeOfDay.SUNSET
    "night": 2,   # TimeOfDay.NIGHT
    "sunrise": 3  # TimeOfDay.SUNRISE
}

# 배경 효과 노드
var background_controller: Node

func _init(controller: Node):
    background_controller = controller

# XML 배경 태그 파싱
func parse_background_element(background_elem: XMLNode) -> void:
    if not background_elem:
        push_error("배경 엘리먼트가 없습니다.")
        return
    
    # 배경 이미지 경로
    var path = background_elem.get_attribute("path", "")
    if path.is_empty():
        push_error("배경 이미지 경로가 지정되지 않았습니다.")
        return
    
    # 전환 타입과 시간
    var transition = background_elem.get_attribute("transition", "fade")
    var duration = background_elem.get_attribute("duration", "1.0").to_float()
    
    # 배경 변경
    background_controller.change_background(path, transition, duration)
    
    # 효과 태그 처리
    for effect in background_elem.get_children():
        match effect.tag_name:
            "weather":
                _parse_weather_effect(effect)
            "time":
                _parse_time_effect(effect)
            "overlay":
                _parse_overlay_effect(effect)

# 날씨 효과 파싱
func _parse_weather_effect(weather_elem: XMLNode) -> void:
    var type = weather_elem.get_attribute("type", "clear").to_lower()
    if not WEATHER_MAPPING.has(type):
        push_error("알 수 없는 날씨 타입: " + type)
        return
    
    var duration = weather_elem.get_attribute("duration", "1.0").to_float()
    background_controller.set_weather(WEATHER_MAPPING[type], duration)

# 시간 효과 파싱
func _parse_time_effect(time_elem: XMLNode) -> void:
    var time = time_elem.get_attribute("value", "day").to_lower()
    if not TIME_MAPPING.has(time):
        push_error("알 수 없는 시간 값: " + time)
        return
    
    var duration = time_elem.get_attribute("duration", "2.0").to_float()
    background_controller.set_time_of_day(TIME_MAPPING[time], duration)

# 오버레이 효과 파싱 (추가 기능을 위한 확장)
func _parse_overlay_effect(overlay_elem: XMLNode) -> void:
    # 오버레이 효과 구현은 향후 확장을 위해 예약
    pass
extends Control


################################################################################
##								PUBLIC
################################################################################

func open() -> void:
	show()
	$HBox/VBox/OverallVolume/Slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

################################################################################
##								PRIVATE
################################################################################

func _ready() -> void:
	hide()


func _on_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))


func _on_DisplaySelect_item_selected(index):
	if index == 0:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
	if index == 1:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED

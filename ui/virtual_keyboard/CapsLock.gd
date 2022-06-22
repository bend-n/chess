extends KeyUtils
class_name CapsLock


func _toggled(button_pressed: bool) -> void:
	if button_pressed:
		simulate_key_input_event(KEY_CAPSLOCK)
	else:
		simulate_key_input_event(KEY_CAPSLOCK, 0, false)

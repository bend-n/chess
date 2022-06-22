extends Button
class_name KeyUtils

var is_pressed = false


func simulate_key_input_event(scancode: int, unicode := 0, pressed := true):
	var i = InputEventKey.new()
	i.pressed = pressed
	i.scancode = scancode
	i.unicode = unicode
	Input.parse_input_event(i)


func is_mouse(event) -> bool:
	return event is InputEventMouseButton and event.button_index == BUTTON_LEFT


func _input(event: InputEvent) -> void:
	if is_mouse(event):
		if !event.pressed and is_pressed:
			_release()
	elif event is InputEventMouseMotion:
		if !get_global_rect().has_point(event.position):
			_release()


func _release():
	if is_pressed != false:
		is_pressed = false
		released()


func _pressed():
	is_pressed = true
	pressed()


func pressed() -> void:
	pass


func released() -> void:
	pass

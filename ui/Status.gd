extends Label
class_name StatusLabel


func set_text(newtext: String, time := 7) -> void:
	__set_text(newtext)
	if time != 0:
		yield(get_tree().create_timer(time), "timeout")
		__set_text("")


func __set_text(_text: String = ""):
	text = _text
	visible = text != ""

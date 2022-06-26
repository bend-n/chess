extends Label
class_name InfoLabel


func set_text(new_text: String, time := 5) -> void:
	show()
	text = new_text
	if time != 0:
		yield(get_tree().create_timer(time), "timeout")
		text = ""
		hide()

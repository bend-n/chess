extends Label
class_name StatusLabel


func set_text(newtext: String, time := 7) -> void:
	print("set to ", newtext)
	text = newtext
	if time != 0:
		yield(get_tree().create_timer(time), "timeout")
		text = ""

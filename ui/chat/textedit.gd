extends ExpandableTextEdit

signal send(msg)


func _input(event: InputEvent) -> void:
	if (
		event is InputEventKey
		and OS.get_scancode_string(event.get_scancode_with_modifiers()) in ["Kp Enter", "Enter"]
		and event.pressed
	):
		get_tree().set_input_as_handled()
		if has_focus():
			text = text.strip_edges()
			if text:
				emit_signal("send", text)
				text = ""
				emit_signal("text_changed")
		else:
			grab_focus()

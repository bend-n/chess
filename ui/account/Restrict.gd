extends LineEdit
class_name Restrict


func _on_text_changed(new_text: String):
	var pos = caret_position
	text = new_text.strip_edges()
	caret_position = pos

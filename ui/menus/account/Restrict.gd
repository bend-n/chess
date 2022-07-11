extends LineEdit
class_name Restrict


func _on_text_changed(new_text: String):
	var pos = caret_position
	text = new_text.strip_edges().strip_escapes()
	caret_position = pos


func _ready():
	connect("text_changed", self, "_on_text_changed")

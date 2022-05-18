extends LineEdit
class_name HexInput

var color: Color setget set_color

signal color_changed(color)


func set_color(newcolor):
	color = newcolor
	var pos = caret_position
	text = "#" + color.to_html(false)
	caret_position = pos  # make it in the right place


func _text_entered(new_text: String):
	set_color(Color(new_text))
	emit_signal("color_changed", color)

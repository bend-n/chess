extends Control
class_name ColorPickerButtonBetter

onready var popup: Popup = $Popup
onready var colorpicker := $Popup/ColorPicker

signal changed(color)
signal newcolor(color)

var color: Color setget set_color


func set_color(newcolor: Color) -> void:
	color = newcolor
	add_color_override("font_color", color)


func done(clr: Color) -> void:
	set_color(clr)
	popup.hide()
	emit_signal("newcolor", clr)


func _pressed() -> void:
	var rect := popup.get_global_rect()
	rect.position = rect_global_position + Vector2(50, 50)
	popup.popup(rect)
	colorpicker.open(color)


func _on_popup_hidden():
	done(colorpicker.color)


func changed(clr: Color):
	set_color(clr)
	emit_signal("changed", clr)

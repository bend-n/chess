extends Control
class_name ColorPickerButtonBetter

onready var popup: Popup = $Popup
onready var colorpicker := $Popup/ColorPicker

signal newcolor(color)

var color: Color setget set_color


func set_color(newcolor: Color) -> void:
	color = newcolor
	add_color_override("font_color", color)


func _on_ColorPicker_done(newcolor: Color) -> void:
	set_color(newcolor)
	popup.hide()
	colorpicker.hide()
	emit_signal("newcolor", color)


func _pressed() -> void:
	var rect := popup.get_global_rect()
	rect.position = rect_global_position + Vector2(50, 50)
	popup.popup(rect)
	colorpicker.open(color)

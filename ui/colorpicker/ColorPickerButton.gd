extends Control
class_name ColorPickerButtonBetter

onready var colorpicker = $"ColorPicker"

signal newcolor(color)

var color: Color setget set_color


func set_color(newcolor):
	color = newcolor
	add_color_override("font_color", color)
	colorpicker.color = color


func _ready():
	colorpicker.set_as_toplevel(true)
	colorpicker.rect_global_position = $Position.rect_global_position
	$Position.queue_free()


func _on_ColorPicker_done(newcolor: Color):
	set_color(newcolor)
	colorpicker.hide()
	emit_signal("newcolor", color)

extends Button
class_name ColorPickerButtonBetter

onready var colorpicker = $"ColorPicker"

signal newcolor(color)

var color: Color setget set_color


func set_color(newcolor):
	color = newcolor
	add_color_override("font_color", color)
	colorpicker.color = color
	colorpicker.update_hex_and_preview()


func _ready():
	colorpicker.set_as_toplevel(true)
	colorpicker.rect_global_position = $Position.rect_global_position
	$Position.queue_free()
	# VisualServer.canvas_item_set_z_index(colorpicker.get_canvas_item(), 5)


func _on_pressed():
	colorpicker.show()


func _on_ColorPicker_done(newcolor: Color):
	set_color(newcolor)
	colorpicker.hide()
	emit_signal("newcolor", color)

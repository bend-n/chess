extends Control
class_name ColorPickerBetter  # when you dont like the native color picker so you make your own

var color: Color

var _manual_change := false

signal color_changed(color)
signal done(color)

onready var hex = $Panel/hex
onready var rgb = $Panel/H/rgb.get_children()
onready var preview = $Panel/H/Preview


func _ready():
	update_hex_and_preview(false)


func update_r(value: float):
	if _manual_change:
		return
	color.r = value / 255
	update_hex_and_preview()


func update_b(value: float):
	if _manual_change:
		return
	color.b = value / 255
	update_hex_and_preview()


func update_g(value: float):
	if _manual_change:
		return
	color.g = value / 255
	update_hex_and_preview()


func update_hex_and_preview(to_signal := true):  # update the hex and preview
	_manual_change = true
	rgb[0].value = color.r * 255
	rgb[1].value = color.g * 255
	rgb[2].value = color.b * 255
	_manual_change = false
	var pos = hex.caret_position
	hex.text = "#" + color.to_html(false)
	hex.caret_position = pos  # make it in the right place
	preview.color = color
	if to_signal:
		emit_signal("color_changed", color)


func _on_hex_text_entered(new_text: String):
	color = Color(new_text)
	update_hex_and_preview()


func _on_OKButton_pressed():
	emit_signal("done", color)

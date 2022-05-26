extends Control
class_name ColorPickerBetter  # when you dont like the native color picker so you make your own

var color: Color = Color.white setget set_color

signal color_changed(color)
signal done(color)

onready var oldcolorview := $V/H2/OldColorView
onready var newcolorpreview := $V/H2/NewColorPreview
onready var colorselect := $V/H/ColorSelect
onready var hueslider := $V/H/HueSlider
onready var closebutton := $V/H2/Close


func open(newcolor: Color) -> void:
	oldcolorview.color = newcolor
	show()
	set_color(newcolor)


func update_color() -> void:
	newcolorpreview.color = color
	colorselect.color = color


func set_color(newcolor: Color) -> void:
	color = newcolor
	update_color()
	emit_signal("color_changed", newcolor)


func done() -> void:
	closebutton._focused(false)
	emit_signal("done", color)


func _color_changed(newcolor: Color) -> void:
	if newcolor != color:
		set_color(newcolor)

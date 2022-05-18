extends Control
class_name ColorPickerBetter  # when you dont like the native color picker so you make your own

var color: Color = Color.white setget set_color

signal color_changed(color)
signal done(color)

onready var oldcolorview = $Panel/V/H2/OldColorView
onready var newcolorpreview = $Panel/V/H2/NewColorPreview
onready var hex = $Panel/V/hex
onready var colorselect = $Panel/V/H/ColorSelect
onready var hueslider = $Panel/V/H/HueSlider

func open():
	oldcolorview.color = color
	update_color()
	show()

func _ready():
	if has_node("/root/ColorPicker"):
		open() # for testing

func update_color():
	newcolorpreview.color = color
	hex.color = color
	colorselect.color = color
	hueslider.hue = color.h

func set_color(newcolor):
	color = newcolor
	update_color()
	emit_signal("color_changed", newcolor)


func _on_OKButton_pressed():
	emit_signal("done", color)


func _color_changed(newcolor: Color):
	if newcolor != color:
		set_color(newcolor)

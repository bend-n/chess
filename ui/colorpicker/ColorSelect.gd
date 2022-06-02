extends Control
class_name ColorSelect

var color: Color setget set_color
var last_clicked_pos := Vector2.ZERO

onready var shader_holder := $ShaderHolder

signal color_changed(color)


func set_color(newcolor: Color, sig := false) -> void:
	if newcolor != color:
		color = newcolor
		shader_holder.material.set_shader_param("hue", color.h)
		update()
		if sig:
			emit_signal("color_changed", color)


func _gui_input(event: InputEvent) -> void:
	if Input.is_action_pressed("click") and event is InputEventMouse:
		last_clicked_pos = event.position
		var saturation := clamp(last_clicked_pos.x / rect_size.x, 0, 1)
		var value := clamp(1 - (last_clicked_pos.y / rect_size.y), 0, 1)
		set_color(Color.from_hsv(color.h, saturation, value), true)


func _draw() -> void:
	var draw_color := color.inverted()

	if color.h == 0:
		var vlinex := clamp(last_clicked_pos.x, 0, rect_size.x)

		draw_line(Vector2(vlinex, 0), Vector2(vlinex, rect_size.x), draw_color)

		var hliney = clamp(last_clicked_pos.y, 0, rect_size.y)

		draw_line(Vector2(0, hliney), Vector2(rect_size.x, hliney), draw_color)
	else:
		var vlinex = color.s * rect_size.x

		draw_line(Vector2(vlinex, 0), Vector2(vlinex, rect_size.y), draw_color)

		var hliney = rect_size.y - color.v * rect_size.y

		draw_line(Vector2(0, hliney), Vector2(rect_size.x, hliney), draw_color)


func _hue_changed(hue: float) -> void:
	set_color(Color.from_hsv(hue, color.s, color.v), true)

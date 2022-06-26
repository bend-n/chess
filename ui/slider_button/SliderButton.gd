extends Control
class_name SliderButton

signal toggled(enabled)

export(bool) var enabled = true setget set_enabled  # true is to the right
export(Color) var on_color := Color.green
export(Color) var off_color := Color.red
var pos: float = 1  # 0-1


func set_enabled(new_enabled: bool) -> void:
	enabled = new_enabled
	emit_signal("toggled", enabled)
	set_process(true)


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		set_enabled(!enabled)


func _draw():
	var x: float = lerp(rect_size.y / 2, rect_size.x - rect_size.y / 2, pos)
	var c: Color = lerp(off_color, on_color, pos)
	draw_circle(Vector2(x, rect_size.y / 2), (rect_size.y / 2) + .3, c)


func _process(_delta):
	update()
	if enabled and pos <= 1:
		pos = lerp(pos, 1, 0.1)
	elif !enabled and pos >= 0:
		pos = lerp(pos, 0, 0.1)
	if is_equal_approx(pos, 1) or is_equal_approx(pos, 0):
		set_process(false)

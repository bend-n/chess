extends ColorRect

signal clicked

var circle_on := false

onready var circle := $CircleHolder/Circle


func _ready() -> void:
	circle.rect_min_size = Globals.grid.piece_size / 4
	circle.material.set_shader_param("color", Globals.grid.overlay_color)
	circle.visible = false
	rect_min_size = Globals.grid.piece_size
	rect_size = rect_min_size
	if Globals.spectating:
		mouse_default_cursor_shape = CURSOR_FORBIDDEN
	else:
		mouse_default_cursor_shape = CURSOR_POINTING_HAND


func set_circle(boolean: bool) -> void:
	circle_on = boolean
	circle.visible = boolean


func _gui_input(event: InputEvent):
	if !Globals.spectating and event is InputEventMouseButton and Input.is_action_pressed("click"):
		emit_signal("clicked")
		get_tree().set_input_as_handled()

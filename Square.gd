extends MarginContainer
class_name BackgroundSquare

signal clicked
signal right_clicked

var color: Color

onready var circle: TextureRect = $CircleHolder/Circle
onready var move_indicator: ColorRect = $MoveIndicator
onready var b_square: ColorRect = $BackgroundSquare


func _ready() -> void:
	move_indicator.color = Globals.grid.last_move_indicator_color
	b_square.color = color
	circle.rect_min_size = Globals.grid.piece_size / 4
	circle.material.set_shader_param("color", Globals.grid.overlay_color)
	circle.visible = false
	rect_min_size = Globals.grid.piece_size
	if Globals.spectating:
		mouse_default_cursor_shape = CURSOR_FORBIDDEN
	else:
		mouse_default_cursor_shape = CURSOR_POINTING_HAND


func _gui_input(event: InputEvent):
	if !Globals.spectating and event is InputEventMouseButton and event.pressed:
		emit_signal("clicked" if event.button_index == BUTTON_LEFT else "right_clicked")
		get_tree().set_input_as_handled()

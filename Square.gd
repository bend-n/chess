extends ColorRect
class_name BackgroundSquare

# warning-ignore-all:unused_signal
signal clicked
signal right_clicked

var move_indicators := []
var square: String

onready var circle: TextureRect = $CircleHolder/Circle
onready var move_indicator: ColorRect = $MoveIndicator


func _ready() -> void:
	connect("clicked", self, "clicked")
	move_indicator.color = Globals.grid.last_move_indicator_color
	circle.material.set_shader_param("color", Globals.grid.overlay_color)
	if Globals.spectating:
		mouse_default_cursor_shape = CURSOR_FORBIDDEN
	else:
		mouse_default_cursor_shape = CURSOR_POINTING_HAND
	size()


func size():
	circle.rect_min_size = Globals.grid.piece_size / 4


func check_piece_above() -> bool:
	return is_instance_valid(Globals.grid.get_piece(square))


func _gui_input(event: InputEvent):
	if !Globals.spectating and event is InputEventMouseButton and event.pressed:
		emit_signal("clicked" if event.button_index == BUTTON_LEFT else "right_clicked")
		get_tree().set_input_as_handled()


func _focus_exited():
	if check_piece_above():
		Globals.grid.get_piece(square).background.hide()
	for m in move_indicators:
		if is_instance_valid(m):
			m.hide()
	move_indicators.clear()


func clicked():
	var b = Globals.grid
	if check_piece_above() and b.chess.turn == Globals.team and not Globals.spectating:
		var p = b.get_piece(square)
		if p.color == Globals.team:
			p.background.show()
			var movs = b.chess.__generate_moves({"square": square, "verbose": true})
			for m in movs:
				var i = b.board[m.to].frame if m.flags & Chess.BITS.CAPTURE else b.background_array[m.to].circle
				move_indicators.append(i)
				i.show()

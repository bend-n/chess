extends ColorRect
class_name BackgroundSquare

# warning-ignore-all:unused_signal
signal clicked
signal right_clicked

var move_indicators := []
var square: String

onready var circle: TextureRect = $Circle
onready var move_indicator: ColorRect = $MoveIndicator
onready var premove_indicator: ColorRect = $PremoveIndicator

var b


func _ready() -> void:
	move_indicator.color = b.last_move_indicator_color
	premove_indicator.color = b.premove_color
	mouse_default_cursor_shape = CURSOR_FORBIDDEN if b.spectating else CURSOR_POINTING_HAND
	Events.connect("turn_over", self, "clear_move_indicators")


func check_piece_above() -> bool:
	return is_instance_valid(b.get_piece(square))


func _gui_input(event: InputEvent):
	if !b.spectating and event is InputEventMouseButton and event.pressed:
		emit_signal("clicked" if event.button_index == BUTTON_LEFT else "right_clicked")
		get_tree().set_input_as_handled()


func _focus_exited():
	clear_move_indicators()


func clear_move_indicators():
	if check_piece_above():
		b.get_piece(square).background.hide()
	for m in move_indicators:
		if is_instance_valid(m):
			m.hide()
	move_indicators.clear()


func show_move_indicators():
	clear_move_indicators()
	var p = b.get_piece(square)
	p.background.show()
	var movs = b.chess.__generate_moves({"square": square})
	for m in movs:
		var i = b.board[m.to].frame if m.flags & Chess.BITS.CAPTURE else b.background_array[m.to].circle
		move_indicators.append(i)
		i.show()


func show_premove_indicators():
	clear_move_indicators()
	var p = b.get_piece(square)
	p.background.show()
	var movs = b.chess.piece_moves(square, p.type, b.team, false)
	for m in movs:
		var _p = b.board[m.to]
		var i = b.background_array[m.to].circle
		if is_instance_valid(_p):
			i = _p.frame
		move_indicators.append(i)
		i.show()

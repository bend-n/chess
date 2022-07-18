extends Control
class_name Grid

const PieceScene := preload("res://piece/Piece.tscn")
const Square := preload("res://Square.tscn")

### for the sandisplay
signal add_to_pgn(move)
signal clear_pgn
signal load_pgn(moves)
signal remove_last

var move_indicators: PoolIntArray = []

var piece_size: Vector2

export(Color) var overlay_color := Color(0.078431, 0.333333, 0.117647, 0.498039)
export(Color) var last_move_indicator_color := Color(0.74902, 0.662745, 0.223529, 0.498039)
export(Color) var clockrunning_color := Color(0.219608, 0.278431, 0.133333)
export(Color) var clockrunninglow := Color(0.47451, 0.172549, 0.164706)
export(Color) var clocklow := Color(0.313726, 0.156863, 0.14902)

var board = []  # has `get_piece(algebraic position)` and `set_piece(algebraic position)` for ease of use


func get_piece(alg: String) -> Piece:
	return board[Chess.SQUARE_MAP[alg]]


func set_piece(alg: String, p: Piece) -> void:
	board[Chess.SQUARE_MAP[alg]] = p


var flipped = false
var labels = {numbers = [], letters = []}
var background_array = []
var last_clicked

export(NodePath) var sidebar_path = @""
onready var sidebar := get_node_or_null(sidebar_path)
export(NodePath) var ui_path = @""
onready var darken = $Darken
onready var ui := get_node_or_null(ui_path)
onready var foreground := $Foreground
onready var background := $Background
onready var pieces := $Pieces

var chess := Chess.new()


func _init():
	Globals.grid = self


func _exit_tree():
	Globals.grid = null


func _resized():
	rect_pivot_offset = (piece_size * 8) / 2
	piece_size = rect_size / 8
	piece_size.x = clamp(piece_size.x, 0, piece_size.y)
	piece_size.y = clamp(piece_size.y, 0, piece_size.x)
	print(piece_size)
	if !(board.empty() && background_array.empty()):
		resize_board()


func _ready():
	if !piece_size:
		_resized()
	Events.connect("turn_over", self, "_on_turn_over")
	PacketHandler.connect("move_data", self, "move")
	create_pieces()
	create_squares()
	create_labels()


func resize_board():
	resize_squares()
	resize_pieces()


func resize_squares() -> void:
	for i in Chess.SQUARE_MAP.values():
		var square: BackgroundSquare = background_array[i]
		square.size()


func create_squares() -> void:  # create the board
	background_array.resize(128)
	for i in Chess.SQUARE_MAP.values():
		var alg := Chess.algebraic(i)
		var square := Square.instance()  # create a square
		square.name = alg
		square.square = alg
		square.hint_tooltip = alg
		square.color = (Globals.board_color1 if Chess.square_color(alg) == "light" else Globals.board_color2)  # set the color
		background.add_child(square)  # add the square to the background
		square.connect("clicked", self, "square_clicked", [alg])  # connect the clicked event
		background_array[i] = square  # add the square to the background array
	find_node("Arrows")._setup(self)  # initialize the arrows


func create_labels() -> void:
	for i in range(8):
		labels.letters.append(init_label(i, Vector2(i, 7), "abcdefgh"[i], Vector2(10, -10), Label.VALIGN_BOTTOM))
		labels.numbers.append(init_label(i, Vector2(7, i), str(8 - i), Vector2(-10, 10), 0, Label.VALIGN_BOTTOM))


func init_label(i: int, position: Vector2, text: String, off := Vector2.ZERO, valign := 0, align := 0) -> Label:
	var label := Label.new()
	label.rect_size = piece_size
	label.align = align
	label.valign = valign
	label.rect_position = (position * piece_size) + off
	label.text = text
	label.add_color_override("font_color", Globals.board_color1 if i % 2 == 0 else Globals.board_color2)
	var font: DynamicFont = load("res://ui/ubuntu-bold.tres").duplicate()
	font.size = 15
	label.add_font_override("font", font)
	foreground.add_child(label)
	return label


func clear_pieces() -> void:
	for i in Chess.SQUARE_MAP.values():
		var p: Piece = board[i]
		if p:
			p.queue_free()
			board[i] = null


func resize_pieces():
	for i in Chess.SQUARE_MAP.values():
		var p: Piece = board[i]
		if p:
			p.size()


func create_pieces():
	board.resize(128)
	for k in Chess.SQUARE_MAP:
		var piece = chess.get(k)
		if piece:
			make_piece(k, piece.type, piece.color)


func make_piece(algebraic: String, piece_type: String, color := "w") -> void:  # make peace
	var piece := PieceScene.instance()  # create a piece
	piece.name = "%s@%s" % [piece_type, algebraic]
	piece.position = algebraic
	piece.type = piece_type
	piece.size()
	piece.color = color
	pieces.add_child(piece)  # add the piece to the grid
	set_piece(algebraic, piece)


func flip_pieces() -> void:
	for i in Chess.SQUARE_MAP.values():
		var spot: Piece = board[i]
		if spot:
			spot.sprite.flip_v = flipped
			spot.sprite.flip_h = flipped


func flip_labels() -> void:
	for i in range(8):
		var numlabel: Label = labels.numbers[i]
		var letlabel: Label = labels.letters[i]
		var number := i + 1 if flipped else 8 - i
		numlabel.text = str(number)
		letlabel.text = "hgfedcba"[number - 1]


func flip_board() -> void:
	sidebar.flip_panels()
	if flipped:
		flipped = false
		rect_rotation = 0
		flip_pieces()
		flip_labels()
	else:
		flipped = true
		rect_rotation = 180
		flip_pieces()
		flip_labels()


func square_clicked(clicked_square: String) -> void:
	if chess.turn != Globals.team or Globals.spectating:
		return
	var p := get_piece(clicked_square)
	if !p or p.color != Globals.team:
		if !is_instance_valid(last_clicked):
			return
		for m in chess.moves({square = last_clicked.position, verbose = true}):
			if m.to == clicked_square && m.from == last_clicked.position:
				move(m.san, false)
				break
		clear_last_clicked()
		return
	last_clicked = p


func move(san: String, is_recieved_move := true) -> void:
	var sound_handled = false
	var move_0x88 = chess.__move_from_san(san, true)
	var valid_moves = chess.moves({square = chess.algebraic(move_0x88.from), stripped = true})
	if valid_moves.find(chess.stripped_san(san)) == -1:
		Log.err("Invalid move")
		return
	chess.__make_move(move_0x88)
	if move_0x88.flags & Chess.BITS.CAPTURE:
		board[move_0x88.to].took()
		SoundFx.play("Capture")
		sound_handled = true
	elif move_0x88.flags & Chess.BITS.EP_CAPTURE:
		var to_take := Chess.offset(move_0x88.to, Vector2(0, 1 * -1 if chess.turn == Chess.WHITE else 1))
		get_piece(to_take).took()
		SoundFx.play("Capture")
		sound_handled = true
	elif move_0x88.flags & Chess.BITS.KSIDE_CASTLE:  # kingside castling
		var rook_pos := Chess.offset(move_0x88.to, Vector2(1, 0))
		var _rook := get_piece(rook_pos).move(Chess.offset(move_0x88.to, Vector2(-1, 0)))
	elif move_0x88.flags & Chess.BITS.QSIDE_CASTLE:  # queenside
		var rook_pos := Chess.offset(move_0x88.to, Vector2(-2, 0))
		var _rook := get_piece(rook_pos).move(Chess.offset(move_0x88.to, Vector2(1, 0)))
	if move_0x88.flags & Chess.BITS.PROMOTION:  #promotion wow
		var p: Piece = board[move_0x88.from].move(Chess.algebraic(move_0x88.to))
		if !is_recieved_move:  # was my turn, this is my move
			yield(p.tween, "tween_all_completed")
			p.open_promotion_previews()
			yield(p, "promotion_decided")
			move_0x88["promotion"] = p.promote_to
			san = chess.__move_to_san(move_0x88)  # update the san with new promotion data
			p.queue_free()
		else:  # was opponents turn, this is opponents move: promotion is already chosen
			p.queue_free()  # the q_f above happens after a dozen yields
		# the move animation is useless if its not my turn
		# but it changes p.position, so its usefull.
		make_piece(p.position, move_0x88.promotion, p.color)
		SoundFx.play("Move" if move_0x88.flags & Chess.BITS.NORMAL else "Capture")
		sound_handled = true
	else:  # not promotion: from **always** moves to `to`
		var _p = board[move_0x88.from].move(Chess.algebraic(move_0x88.to))
	if !is_recieved_move:
		PacketHandler.send_mov(san)
	if !sound_handled:
		SoundFx.play("Move")
	emit_signal("add_to_pgn", san)
	Events.emit_signal("turn_over")


func clear_last_clicked():
	last_clicked = null
	darken.hide()


func draw(reason := "") -> void:
	var string = "draw by " + reason
	ui.set_status(string, 0)
	SoundFx.play("Victory")
	Events.emit_signal("game_over", string, true)
	PacketHandler.stopgame("game over")


func win(winner: String, reason := "") -> void:
	var string = "%s won the game by %s" % [Utils.expand_color(winner), reason]
	ui.set_status(string, 0)  #: black won the game by checkmate
	Events.emit_signal("game_over", string, true)
	SoundFx.play("Victory")
	PacketHandler.stopgame("game over")


func load_pgn(pgn: String) -> void:
	chess.load_pgn(pgn, {sloppy = true})
	clear_pieces()
	create_pieces()
	emit_signal("clear_pgn")
	var movs: PoolStringArray = Pgn.parse(pgn).moves
	emit_signal("load_pgn", movs)
	Events.emit_signal("turn_over")


func undo(two: bool = false) -> void:
	Globals.chat.server("undid move %s" % chess.undo().san)
	emit_signal("remove_last")
	if two:
		Globals.chat.server("undid move %s" % chess.undo().san)
		emit_signal("remove_last")
	clear_pieces()
	clear_last_clicked()
	create_pieces()
	Events.emit_signal("turn_over")


func _on_turn_over():
	SaveLoad.save("user://game.json", {pgn = chess.pgn(), fen = chess.fen()})
	clear_last_clicked()
	check_game_over()
	create_last_move_indicators()


func check_game_over():
	if chess.in_checkmate():
		# they won if its my turn, i won if its their turn.
		win(Globals.team if Globals.team != chess.turn else Chess.__swap_color(Globals.team), "checkmate")
	elif chess.half_moves >= 50:
		draw("fifty move rule")
	elif chess.in_stalemate():
		draw("stalemate")
	elif chess.insufficient_material():
		draw("insufficient material")
	elif chess.in_threefold_repetition():
		draw("threefold repetition")


func create_last_move_indicators():
	for i in move_indicators:
		background_array[i].move_indicator.hide()
	if !chess.__history:
		return
	var m: Dictionary = chess.__history[-1].move
	background_array[m.from].move_indicator.show()
	background_array[m.to].move_indicator.show()
	move_indicators = [m.from, m.to]

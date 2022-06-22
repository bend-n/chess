extends Control
class_name Grid

const PieceScene := preload("res://Piece.tscn")
const Square := preload("res://Square.tscn")

const piece_size := Vector2(80, 80)

export(Color) var overlay_color := Color(0.078431, 0.333333, 0.117647, 0.498039)
export(Color) var clockrunning_color := Color(0.219608, 0.278431, 0.133333)
export(Color) var clockrunninglow := Color(0.47451, 0.172549, 0.164706)
export(Color) var clocklow := Color(0.313726, 0.156863, 0.14902)

var matrix := []
var stop_input := true
var background_array := []
var last_clicked: Piece = null
var flipped := false

signal move_decided

var labels := {letters = [], numbers = []}

onready var background := $Background
onready var ASSETS_PATH: String = "res://assets/pieces/%s/" % Globals.piece_set
onready var foreground := $Foreground
onready var pieces := $Pieces
export(NodePath) onready var ui = get_node(ui)
export(NodePath) onready var sidebar = get_node(sidebar)

enum { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }


func _init() -> void:
	Globals.grid = self


func _ready() -> void:
	rect_pivot_offset = rect_size / 2
	if PacketHandler:
		PacketHandler.connect("move_data", self, "play_san")
	init_board()  # create the tile squares
	init_matrix()  # create 2d matrix
	init_pieces()  # create the pieces
	init_labels()  # add the labels
	Events.connect("turn_over", self, "_on_turn_over")  # listen for turn_over events
	Events.connect("outoftime", self, "_on_outoftime")  # listen for timeout events

	Debug.monitor(self, "last_clicked")
	stop_input = false


func _exit_tree() -> void:
	Globals.grid = null  # reset the globals grid when leaving tree


func _input(event: InputEvent) -> void:  # input
	if event.is_action_released("debug"):  # if debug
		print_matrix_pretty(matrix)  # print the matrix


static func print_matrix_pretty(mat: Array) -> void:  # print the matrix
	var topper_header := "┏━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┓"
	var middle_header := "┣━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━┫"
	var middish_heads := "┗━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━┫"
	var smaller_heads := "    ┗━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┛"
	var letter_header := "    ┃ a ┃ b ┃ c ┃ d ┃ e ┃ f ┃ g ┃ h ┃"
	var ender := " ┃ "  # for pretty prints
	for j in range(8):  # for each row
		var r: Array = mat[j]  # get the row
		if j == 0:
			print(topper_header)  # print the top border
		else:
			print(middle_header)  # print the middle border
		var row := "%s %s%s" % [ender.strip_edges(), 8 - j, ender]  # init the string
		for i in range(8):  # for each column
			if typeof(r[i]) != TYPE_STRING:
				var c: Piece = r[i]  # get the column
				row += "%s%s" % [c.mininame, ender] if c else " " + ender  # add the piece
			else:
				row += "%s%s" % [r[i] if r[i] else " ", ender]
		print(row)  # print the string
	print("%s\n%s\n%s" % [middish_heads, letter_header, smaller_heads])


func reload_sprites() -> void:
	for i in range(8):
		for j in range(8):
			if matrix[i][j]:
				matrix[i][j].load_texture()


func flip_pieces() -> void:
	for i in range(8):
		for j in range(8):
			var spot: Piece = matrix[i][j]
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


func flip_panels() -> void:
	pass


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


func init_labels() -> void:
	foreground.offset = rect_global_position
	for i in range(8):
		labels.letters.append(
			init_label(i, Vector2(i, 7), "abcdefgh"[i], VALIGN_BOTTOM, Label.ALIGN_LEFT, Vector2(10, -10))
		)
		labels.numbers.append(
			init_label(i, Vector2(7, i), str(8 - i), VALIGN_TOP, Label.ALIGN_RIGHT, Vector2(-10, 10))
		)


func init_label(i: int, position: Vector2, text: String, valign := 0, align := 0, off := Vector2.ZERO) -> Label:
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


func drawed(reason := "") -> void:
	ui.set_status("draw by " + reason, 0)
	Events.emit_signal("game_over")
	SoundFx.play("Draw")
	yield(get_tree().create_timer(5), "timeout")
	Events.emit_signal("go_back")


func win(winner: bool, reason := "") -> void:
	ui.set_status("%s won the game by %s" % ["white" if winner else "black", reason], 0)  #: black won the game by checkmate
	Events.emit_signal("game_over")
	Log.info("%s won the game in %s turns!" % ["white" if winner else "black", Globals.fullmove])
	SoundFx.play("Victory")
	yield(get_tree().create_timer(5), "timeout")
	Events.emit_signal("go_back")


func check_in_check(prin := false) -> bool:  # check if in_check
	for i in range(0, 8):  # for each row
		for j in range(0, 8):  # for each column
			var spot: Piece = matrix[i][j]  # get the square
			if spot and spot.white != Globals.turn:  # enemie
				if spot.can_attack_piece(Globals.white_king if Globals.turn else Globals.black_king):  # if it can take the king
					if prin:
						# control never flows here
						Globals.in_check = true  # set in_check
						Globals.checking_piece = spot  # set checking_piece
						SoundFx.play("Check")
						Log.debug("check")
					return true  # stop at the first check found
	return false


func can_move() -> bool:
	for i in range(0, 8):  # for each row
		for j in range(0, 8):  # for each column
			var spot: Piece = matrix[i][j]  # get the square
			if spot and spot.white == Globals.turn:
				if spot.can_move():
					Log.debug("%s %s can mov!" % [Globals.get_turn(), spot.shortname])
					return true

	Log.debug("can no mov!")
	return false


func init_matrix() -> void:  # create the matrix
	for i in range(8):  # for each row
		matrix.append([])  # add a row
		for _j in range(8):  # for each column
			matrix[i].append(null)  # add a square


func make_piece(position: Vector2, piece_type: int, white: bool = true, visible: bool = true) -> void:  # make peace
	var piece := PieceScene.instance()  # create a piece
	piece.name = Utils.to_str(piece_type)
	piece.script = load("res://pieces/%s.gd" % Utils.to_str(piece_type))  # set the script
	piece.real_position = position  # set the real position
	piece.visible = visible
	piece.rect_global_position = position * piece_size  # set the global position
	piece.white = white  # set its team
	pieces.add_child(piece)  # add the piece to the grid
	matrix[position.y][position.x] = piece


func init_board() -> void:  # create the board
	for x in range(8):
		for y in range(8):  # for each column
			var square := Square.instance()  # create a square
			square.name = Utils.to_algebraic(Vector2(y, x))
			square.hint_tooltip = square.name
			square.rect_min_size = piece_size  # set the size
			square.color = Globals.board_color1 if (x + y) % 2 == 0 else Globals.board_color2  # set the color
			background.add_child(square)  # add the square to the background
			square.connect("clicked", self, "square_clicked", [Vector2(y, x)])  # connect the clicked event
			background_array.append(square)  # add the square to the background array


func get_background_element(pos: Vector2) -> ColorRect:
	return background_array[8 * pos.y + pos.x]


func init_pieces(visible: bool = true) -> void:  # add the pieces
	load_fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", visible)


func check_for_circle(position: Vector2) -> bool:  # check for a circle, validating movement
	return get_background_element(position).circle_on


func check_for_frame(position: Vector2) -> bool:  # check for a frame, validating taking
	if !is_instance_valid(matrix[position.y][position.x]):  # if there is no piece
		return false  # there is no frame
	return matrix[position.y][position.x].frameon  # return if the frame is on


func square_clicked(position: Vector2) -> void:  # square clicked
	if stop_input or Globals.turn != Globals.team or Globals.spectating:
		return
	Log.debug(Utils.to_algebraic(position) + " clicked")
	var spot: Piece = matrix[position.y][position.x]  # get the spot
	if !spot or spot.white != Globals.team:
		if !is_instance_valid(last_clicked):
			return
		if check_for_frame(position):  # takeable
			handle_take(position)
			stop_input = true
			emit_signal("move_decided")
		elif check_for_circle(position):  # see if theres a circle at the position
			handle_move(position)  # move
			stop_input = true
			emit_signal("move_decided")
		if last_clicked:
			last_clicked.clear_clicked()  # remove the circles
			last_clicked = null  # set it to null
	elif last_clicked != spot:  # we got a new piece (or pawn) clicked
		if is_instance_valid(last_clicked):  # remove the circles
			last_clicked.clear_clicked()
		last_clicked = spot  # set it to the new spot
		spot.clicked()  # tell the piece shit happeend


func handle_take(position: Vector2) -> void:
	if Utils.is_pawn(last_clicked):  # if its a pawn
		if check_promote(last_clicked, position, "take"):
			return
	var mov = Move.new(SanParse.from_str(last_clicked.shortname), [last_clicked.real_position, position], true)
	PacketHandler.send_mov(mov)  # piece taking piece


func handle_move(position: Vector2) -> void:
	if Utils.is_king(last_clicked) and last_clicked.can_castle:
		for i in range(len(last_clicked.can_castle)):
			var castle_data = last_clicked.can_castle[i]
			if castle_data[0] == position:
				# send some packet
				var mov = Move.new(SanParser.KING, castle_data[3])
				PacketHandler.send_mov(mov)
				return
	if Utils.is_pawn(last_clicked):
		var pawn: Pawn = last_clicked
		if pawn.enpassant:
			for i in range(len(pawn.enpassant)):
				var en_passant_data = pawn.enpassant[i]
				if en_passant_data[0] == position:
					# send some packet
					var mov = Move.new(SanParser.PAWN, [pawn.real_position, position], true)
					PacketHandler.send_mov(mov)
					return
		elif check_promote(pawn, position):
			return
	var mov = Move.new(SanParse.from_str(last_clicked.shortname), [last_clicked.real_position, position])
	PacketHandler.send_mov(mov)


func check_promote(pawn, position, calltype: String = "move") -> bool:
	if pawn.can_promote(position):
		pawn.promote(position, calltype)
		return true
	return false


func clear_fx() -> void:  # clear the circles
	for i in range(8):  # for each row
		for j in range(8):  # for each column
			var square: ColorRect = get_background_element(Vector2(i, j))  # get the square
			square.set_circle(false)  # set the circle to false
			var piece: Piece = matrix[i][j]  # get the piece
			if piece:  # if there is a piece
				piece.set_frame(false)  # clear the frame
			$Darken.hide()


func _on_outoftime(who: bool) -> void:
	win(who, "time")


func _on_turn_over() -> void:
	Globals.checking_piece = null  # reset checking_piece
	Globals.in_check = false  # reset in_check
	check_in_check(true)  # check if in_check
	if !can_move():
		if Globals.in_check:
			win(!Globals.turn, "checkmate")
		else:
			drawed("stalemate")


func play_pgn(pgn: String, instant := false):
	var hitlist = []
	if instant:
		kill_matrix()
		hitlist = pieces.get_children()
	else:
		kill_pieces()
	stop_input = true
	init_pieces(!instant)  # if instant, hide the pieces
	var mvtext = Pgn.parse(pgn).moves
	for san in mvtext:
		play_san(san, instant)  # instant is not working right right now
		# so just change the delay :>
		if instant:
			yield(get_tree(), "idle_frame")
		else:
			yield(get_tree().create_timer(.3), "timeout")
	for i in range(8):
		for j in range(8):
			if matrix[i][j]:
				matrix[i][j].update_visual_position()
				matrix[i][j].show()
	for c in hitlist:
		if is_instance_valid(c):
			c.free()
	stop_input = false


func play_san(san: String, instant := false, set_input := true) -> void:
	Log.debug("playing " + san)
	var san_to_add := san
	var mov = SanParse.parse(san).make_long()
	Globals.add_turn()
	match mov.move_kind.type:
		Move.MoveKind.CASTLE:
			var side = 0 if Globals.turn else 7
			var rook: Rook
			var rook_goto: Vector2
			var kingpos = Vector2(4, side)
			var king: King = Piece.at_pos(kingpos)
			var king_goto: Vector2
			match mov.move_kind.data:
				Move.MoveKind.CASTLETYPES.KING_SIDE:
					rook = Piece.at_pos(Vector2(7, side))
					rook_goto = Vector2(5, side)
					king_goto = Vector2(6, side)
				Move.MoveKind.CASTLETYPES.QUEEN_SIDE:
					rook = Piece.at_pos(Vector2(0, side))
					rook_goto = Vector2(3, side)
					king_goto = Vector2(2, side)
			rook.moveto(rook_goto, instant)
			king.castle(king_goto, instant)
		Move.MoveKind.NORMAL:
			# this handles promotion, taking, enpassant, and moves.
			var positions = mov.move_kind.data
			if mov.promotion != -1:  # promotion part
				Piece.at_pos(positions[0]).promote_to(mov.promotion, mov.is_capture, positions[1], instant)

			elif mov.is_capture:  # taking part
				Globals.reset_halfmove()
				if Piece.at_pos(positions[1]):
					Piece.at_pos(positions[0]).take(Piece.at_pos(positions[1]), instant)
				elif mov.piece == SanParser.PAWN:  # enpassant part
					var pawn: Pawn = Piece.at_pos(positions[0])
					pawn.passant(positions[1], instant)
					san_to_add += " e.p."
			else:  # a very normal move
				var piece = Piece.at_pos(positions[0])
				piece.moveto(positions[1], instant)
				Globals.reset_halfmove()
	Utils.add_move(san_to_add)
	stop_input = false if set_input else stop_input


func load_fen(fen: String, visible: bool = true):
	var data: Dictionary = Fen.parse(fen)
	load_matrix(data.mat, visible)
	Globals.turn = data.turn
	Globals.fullmove = data.fullmove
	Globals.halfmove = data.halfmove


func load_matrix(mat: Array, visible: bool = true):
	if visible:
		kill_pieces()
	for x in range(8):
		for y in range(8):
			var ret = from_str_with_team(mat[y][x])
			if ret[0] != -1:
				make_piece(Vector2(x, y), ret[0], ret[1], visible)


func from_str_with_team(string: String) -> Array:
	var result = SanParser.from_str(string)
	if result != -1:
		return [result, true]
	result = SanParser.from_str(string.to_upper())
	return [result, false]


func kill_pieces():
	for i in pieces.get_children():
		i.free()
	kill_matrix()


func kill_matrix():
	matrix = []
	init_matrix()


func undo(last_pgn := Utils.pop_move()):
	Globals.turn = true
	Globals.fullmove = 1
	Globals.halfmove = 0
	Globals.in_check = false
	Globals.checking_piece = null
	clear_fx()
	play_pgn(last_pgn, true)

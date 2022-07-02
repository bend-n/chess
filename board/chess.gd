extends Node
class_name Chess
# ported from https://github.com/jhlywa/chess.js
const SYMBOLS := "pnbrqkPNBRQK"

const DEFAULT_POSITION := "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

const TERMINATION_MARKERS := ["1-0", "0-1", "1/2-1/2", "*"]

const PAWN_OFFSETS := {
	b = [16, 32, 17, 15],
	w = [-16, -32, -17, -15],
}

const PIECE_OFFSETS := {
	n = [-18, -33, -31, -14, 18, 33, 31, 14],
	b = [-17, -15, 17, 15],
	r = [-16, 1, 16, -1],
	q = [-17, -16, -15, 1, 17, 16, 15, -1],
	k = [-17, -16, -15, 1, 17, 16, 15, -1],
}

var ATTACKS: PoolIntArray = [
	20, 0, 0, 0, 0, 0, 0, 24,  0, 0, 0, 0, 0, 0,20, 0,
	0,20, 0, 0, 0, 0, 0, 24,  0, 0, 0, 0, 0,20, 0, 0,
	0, 0,20, 0, 0, 0, 0, 24,  0, 0, 0, 0,20, 0, 0, 0,
	0, 0, 0,20, 0, 0, 0, 24,  0, 0, 0,20, 0, 0, 0, 0,
	0, 0, 0, 0,20, 0, 0, 24,  0, 0,20, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0,20, 2, 24,  2,20, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 2,53, 56, 53, 2, 0, 0, 0, 0, 0, 0,
   24,24,24,24,24,24,56,  0, 56,24,24,24,24,24,24, 0,
	0, 0, 0, 0, 0, 2,53, 56, 53, 2, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0,20, 2, 24,  2,20, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0,20, 0, 0, 24,  0, 0,20, 0, 0, 0, 0, 0,
	0, 0, 0,20, 0, 0, 0, 24,  0, 0, 0,20, 0, 0, 0, 0,
	0, 0,20, 0, 0, 0, 0, 24,  0, 0, 0, 0,20, 0, 0, 0,
	0,20, 0, 0, 0, 0, 0, 24,  0, 0, 0, 0, 0,20, 0, 0,
   20, 0, 0, 0, 0, 0, 0, 24,  0, 0, 0, 0, 0, 0,20
]

var RAYS: PoolIntArray = [
   17,  0,  0,  0,  0,  0,  0, 16,  0,  0,  0,  0,  0,  0, 15, 0,
	0, 17,  0,  0,  0,  0,  0, 16,  0,  0,  0,  0,  0, 15,  0, 0,
	0,  0, 17,  0,  0,  0,  0, 16,  0,  0,  0,  0, 15,  0,  0, 0,
	0,  0,  0, 17,  0,  0,  0, 16,  0,  0,  0, 15,  0,  0,  0, 0,
	0,  0,  0,  0, 17,  0,  0, 16,  0,  0, 15,  0,  0,  0,  0, 0,
	0,  0,  0,  0,  0, 17,  0, 16,  0, 15,  0,  0,  0,  0,  0, 0,
	0,  0,  0,  0,  0,  0, 17, 16, 15,  0,  0,  0,  0,  0,  0, 0,
	1,  1,  1,  1,  1,  1,  1,  0, -1, -1,  -1,-1, -1, -1, -1, 0,
	0,  0,  0,  0,  0,  0,-15,-16,-17,  0,  0,  0,  0,  0,  0, 0,
	0,  0,  0,  0,  0,-15,  0,-16,  0,-17,  0,  0,  0,  0,  0, 0,
	0,  0,  0,  0,-15,  0,  0,-16,  0,  0,-17,  0,  0,  0,  0, 0,
	0,  0,  0,-15,  0,  0,  0,-16,  0,  0,  0,-17,  0,  0,  0, 0,
	0,  0,-15,  0,  0,  0,  0,-16,  0,  0,  0,  0,-17,  0,  0, 0,
	0,-15,  0,  0,  0,  0,  0,-16,  0,  0,  0,  0,  0,-17,  0, 0,
  -15,  0,  0,  0,  0,  0,  0,-16,  0,  0,  0,  0,  0,  0,-17
]

const SQUARE_MAP := {
	a8 =   0, b8 =   1, c8 =   2, d8 =   3, e8 =   4, f8 =   5, g8 =   6, h8 =   7,
	a7 =  16, b7 =  17, c7 =  18, d7 =  19, e7 =  20, f7 =  21, g7 =  22, h7 =  23,
	a6 =  32, b6 =  33, c6 =  34, d6 =  35, e6 =  36, f6 =  37, g6 =  38, h6 =  39,
	a5 =  48, b5 =  49, c5 =  50, d5 =  51, e5 =  52, f5 =  53, g5 =  54, h5 =  55,
	a4 =  64, b4 =  65, c4 =  66, d4 =  67, e4 =  68, f4 =  69, g4 =  70, h4 =  71,
	a3 =  80, b3 =  81, c3 =  82, d3 =  83, e3 =  84, f3 =  85, g3 =  86, h3 =  87,
	a2 =  96, b2 =  97, c2 =  98, d2 =  99, e2 = 100, f2 = 101, g2 = 102, h2 = 103,
	a1 = 112, b1 = 113, c1 = 114, d1 = 115, e1 = 116, f1 = 117, g1 = 118, h1 = 119
}

const SHIFTS := {p = 0, n = 1, b = 2, r = 3, q = 4, k = 5}

const BITS := {
	NORMAL = 1,
	CAPTURE = 2,
	BIG_PAWN = 4,  # 2 step pawn
	EP_CAPTURE = 8,
	PROMOTION = 16,
	KSIDE_CASTLE = 32,
	QSIDE_CASTLE = 64,
}

const ROOKS := {
	w = [
		{square = SQUARE_MAP.a1, flag = BITS.QSIDE_CASTLE},
		{square = SQUARE_MAP.h1, flag = BITS.KSIDE_CASTLE},
	],
	b = [
		{square = SQUARE_MAP.a8, flag = BITS.QSIDE_CASTLE},
		{square = SQUARE_MAP.h8, flag = BITS.KSIDE_CASTLE},
	],
}
enum { RANK_8, RANK_7, RANK_6, RANK_5, RANK_4, RANK_3, RANK_2, RANK_1 }
enum { PARSER_STRICT, PARSER_SLOPPY }
const BLACK := "b"
const WHITE := "w"
const EMPTY := -1
const PAWN := "p"
const KNIGHT := "n"
const BISHOP := "b"
const ROOK := "r"
const QUEEN := "q"
const KING := "k"
const FLAGS := {
	NORMAL = "n",
	CAPTURE = "c",
	BIG_PAWN = "b",
	EP_CAPTURE = "e",
	PROMOTION = "p",
	KSIDE_CASTLE = "k",
	QSIDE_CASTLE = "q",
}


# parses all of the decorators out of a SAN string
static func stripped_san(move: String) -> String:
	var reg := RegEx.new()
	reg.compile("(\\+|\\#)?(\\?\\?|\\?|\\?!|!|!!)?$")
	return reg.sub(move.replace("=", ""), "")


# this func is used to uniquely identify ambiguous moves
func get_disambiguator(move: Dictionary, moves: Array) -> String:
	var from: int = move.from
	var to: int = move.to
	var piece: String = move.piece

	var ambiguities := 0
	var same_rank := 0
	var same_file := 0
	var ambig_piece: String
	var ambig_to: int
	var ambig_from: int
	for m in moves:
		ambig_from = m.from
		ambig_to = m.to
		ambig_piece = m.piece

		# if a move of the same piece type ends on the same to square, we'll
		# need to add a disambiguator to the algebraic notation
		if piece == ambig_piece && from != ambig_from && to == ambig_to:
			ambiguities += 1

			if rank(from) == rank(ambig_from):
				same_rank += 1

			if file(from) == file(ambig_from):
				same_file += 1

	if ambiguities > 0:
		# if there exists a similar moving piece on the same rank and file as
		# the move in question, use the square as the disambiguator
		if same_rank > 0 && same_file > 0:
			return algebraic(from)
		elif same_file > 0:
			# if the moving piece rests on the same file, use the rank symbol as the
			# disambiguator
			return algebraic(from)[1]
		else:
			# else use the file symbol
			return algebraic(from)[0]
	return ""


static func infer_piece_type(san: String) -> String:
	var piece_type := san[0]
	if piece_type >= "a" && piece_type <= "h":
		return PAWN
	piece_type = piece_type.to_lower()
	if piece_type == "o":
		return KING
	return piece_type


###
### utility functions
###
static func rank(i: int) -> int:
	return i >> 4


static func file(i: int) -> int:
	return i & 15


static func vec2algebraic(pos: Vector2) -> String:
	var column := "abcdefgh"[pos.x]
	var row := str(round(8 - pos.y))
	return column + row


static func algebraic2vec(alg: String) -> Vector2:
	return Vector2("abcdefgh".find(alg[0]), 8 - int(alg[1]))


static func algebraic(i: int) -> String:
	var f := file(i)
	var r := rank(i)
	return "abcdefgh"[f] + "87654321"[r]


static func __swap_color(c: String) -> String:
	return BLACK if c == WHITE else WHITE


static func offset(pos, offset: Vector2) -> String:
	if typeof(pos) == TYPE_STRING:  # algbraic
		return vec2algebraic(algebraic2vec(pos) + offset)
	elif typeof(pos) == TYPE_INT:  # board pos
		return offset(algebraic(pos), offset)  # supreme lazy
	return ""


# begin main functions

var board := []  # stores all the pieces
var kings := {w = EMPTY, b = EMPTY}  # stores the square of the kings
var turn := WHITE  # whose turn is it
var castling := {w = 0, b = 0}  # castling abilities
var ep_square := EMPTY  # current en passant square; will be `e3` if you make `e4`
var half_moves := 0  # halfmove counter
var fullmoves := 1  # fullmove counter
var __history := []


func _init(fen := DEFAULT_POSITION) -> void:
	load_fen(fen)
	board.resize(128)


# removes everything on the board ( 8/8/8/8/8/8/8/8 w - - 0 1 )
func clear() -> void:
	board.resize(0)
	board.resize(128)
	kings = {w = EMPTY, b = EMPTY}
	turn = WHITE
	castling = {w = 0, b = 0}
	ep_square = EMPTY
	half_moves = 0
	fullmoves = 1
	__history = []


# goes back to the default position
func reset() -> void:
	load_fen(DEFAULT_POSITION)


# loads a FEN string. see `fen()`
# returns false in the event of a failure to parse the FEN string.
func load_fen(fen):
	var parsed: Dictionary = Fen.parse(fen)
	if !parsed:
		return false
	clear()

	for x in range(8):
		for y in range(8):
			var piece: String = parsed.mat[y][x]
			if piece:
				put(
					{type = piece.to_lower(), color = WHITE if piece < "a" else BLACK},
					vec2algebraic(Vector2(x, y))
				)
	turn = parsed.turn
	if "K" in parsed.castling:
		castling.w |= BITS.KSIDE_CASTLE
	if "Q" in parsed.castling:
		castling.w |= BITS.QSIDE_CASTLE
	if "k" in parsed.castling:
		castling.b |= BITS.KSIDE_CASTLE
	if "q" in parsed.castling:
		castling.b |= BITS.QSIDE_CASTLE

	ep_square = SQUARE_MAP[parsed.enpassant] if parsed.enpassant != "-" else EMPTY
	half_moves = parsed.halfmove
	fullmoves = parsed.fullmove
	return true


# returns the FEN string of the current position
func fen() -> String:
	var empty := 0
	var pieces := ""
	var i := 0
	while i < SQUARE_MAP.h1 + 1:
		if board[i] == null:
			empty += 1
		else:
			if empty > 0:
				pieces += str(empty)
				empty = 0
			var piece: String = board[i].type
			var color: String = board[i].color
			pieces += piece.to_upper() if color == WHITE else piece.to_lower()

		if (i + 1) & 0x88:
			if empty > 0:
				pieces += str(empty)

			if i != SQUARE_MAP.h1:
				pieces += "/"

			empty = 0
			i += 8
		i += 1

	var cflags := ""
	if castling[WHITE] & BITS.KSIDE_CASTLE:
		cflags += "K"
	if castling[WHITE] & BITS.QSIDE_CASTLE:
		cflags += "Q"
	if castling[BLACK] & BITS.KSIDE_CASTLE:
		cflags += "k"
	if castling[BLACK] & BITS.QSIDE_CASTLE:
		cflags += "q"
	cflags = cflags if cflags else "-"
	var epflags := "-" if ep_square == EMPTY else algebraic(ep_square)

	return "%s %s %s %s %s %s" % [pieces, turn, cflags, epflags, half_moves, fullmoves]


# gets a square from the board
func get(square: String) -> Dictionary:
	var piece = board[SQUARE_MAP[square]]
	return {type = piece.type, color = piece.color} if piece else {}


# PUTs a piece object into the specified square on the board, returns OK on sucess
func put(piece: Dictionary, square: String) -> int:
	# check for valid piece object + valid piece + valid square
	if (
		!("type" in piece && "color" in piece)
		or SYMBOLS.find(piece.type.to_lower()) == -1
		or not square in SQUARE_MAP
	):
		return ERR_INVALID_DATA

	var sq: int = SQUARE_MAP[square]

	# only one king
	if piece.type == KING && !(kings[piece.color] == EMPTY || kings[piece.color] == sq):
		return ERR_ALREADY_EXISTS

	board[sq] = {type = piece.type, color = piece.color}
	if piece.type == KING:
		kings[piece.color] = sq

	return OK


func remove(square) -> Dictionary:
	var piece := get(square)
	if piece:
		board[SQUARE_MAP[square]] = null
		if piece && piece.type == KING:
			kings[piece.color] = EMPTY
	return piece


# warning-ignore:shadowed_variable
func __build_move(board: Array, from: int, to: int, flags: int, promotion := ""):
	var move := {
		color = turn,
		from = from,
		to = to,
		flags = flags,
		piece = board[from].type,
	}

	if promotion:
		move.flags |= BITS.PROMOTION
		move.promotion = promotion

	if board[to]:
		move.captured = board[to].type
	elif flags & BITS.EP_CAPTURE:
		move.captured = PAWN
	return move


# warning-ignore:shadowed_variable
func __add_move(board: Array, moves: Array, from: int, to: int, flags: int) -> void:
	# if pawn promotion
	if board[from].type == PAWN && (rank(to) == RANK_8 || rank(to) == RANK_1):
		var pieces := [QUEEN, ROOK, BISHOP, KNIGHT]
		for p in pieces:
			moves.append(__build_move(board, from, to, flags, p))
	else:
		moves.append(__build_move(board, from, to, flags))


func __generate_moves(options := {}) -> Array:
	var moves := []
	var us := turn
	var them := __swap_color(us)
	var second_rank := {b = RANK_7, w = RANK_2}

	var first_sq: int = SQUARE_MAP.a8 - 1
	var last_sq: int = SQUARE_MAP.h1
	var single_square := false

	# legal moves?
	var legal: bool = options.legal if "legal" in options else true
	var piece_type: String = (
		options.piece.to_lower()
		if "piece" in options and typeof(options.piece) == TYPE_STRING
		else "-1"
	)
	# generating moves for a single square?
	if "square" in options:
		if options.square in SQUARE_MAP:
			last_sq = SQUARE_MAP[options.square]
			first_sq = last_sq - 1
			single_square = true
		else:
			return []

	var i := first_sq
	while i < last_sq:
		i += 1
		# are we off the edge of the board
		if i & 0x88:
			i += 7
			continue
		var piece = board[i]
		if piece == null || piece.color != us:
			continue

		if piece.type == PAWN && (piece_type == "-1" || piece_type == PAWN):
			# single square, non capturing
			var square = i + PAWN_OFFSETS[us][0]
			if square <= SQUARE_MAP.h1 and board[square] == null:
				__add_move(board, moves, i, square, BITS.NORMAL)

				# double square
				var _square: int = i + PAWN_OFFSETS[us][1]
				if second_rank[us] == rank(i) && board[_square] == null:
					__add_move(board, moves, i, _square, BITS.BIG_PAWN)

			# pawn captures
			for j in range(2, 4):
				var _square: int = i + PAWN_OFFSETS[us][j]
				if _square & 0x88:
					continue

				if board[_square] != null && board[_square].color == them:
					__add_move(board, moves, i, _square, BITS.CAPTURE)
				elif _square == ep_square:
					__add_move(board, moves, i, ep_square, BITS.EP_CAPTURE)
		elif piece_type == "-1" || piece_type == piece.type:
			for offset in PIECE_OFFSETS[piece.type]:
				var square := i

				while true:
					square += offset
					if square & 0x88:
						break

					if board[square] == null:
						__add_move(board, moves, i, square, BITS.NORMAL)
					else:
						if board[square].color == us:
							break
						__add_move(board, moves, i, square, BITS.CAPTURE)
						break

					# break, if knight or king
					if piece.type == "n" || piece.type == "k":
						break

	# check for castling if: a) we're generating all moves, or b) we're doing
	# single square move generation on the king's square
	if piece_type == "-1" || piece_type == KING:
		if !single_square || last_sq == kings[us]:
			# king-side castling
			if castling[us] & BITS.KSIDE_CASTLE:
				var castling_from: int = kings[us]
				var castling_to: int = castling_from + 2

				if (
					board[castling_from + 1] == null
					&& board[castling_to] == null
					&& !__attacked(them, kings[us])
					&& !__attacked(them, castling_from + 1)
					&& !__attacked(them, castling_to)
				):
					__add_move(board, moves, kings[us], castling_to, BITS.KSIDE_CASTLE)

			# queen-side castling
			if castling[us] & BITS.QSIDE_CASTLE:
				var castling_from: int = kings[us]
				var castling_to := castling_from - 2

				if (
					board[castling_from - 1] == null
					&& board[castling_from - 2] == null
					&& board[castling_from - 3] == null
					&& !__attacked(them, kings[us])
					&& !__attacked(them, castling_from - 1)
					&& !__attacked(them, castling_to)
				):
					__add_move(board, moves, kings[us], castling_to, BITS.QSIDE_CASTLE)

	# return all pseudo-legal moves (this includes moves that allow the king
	# to be captured)
	if !legal:
		return moves

	# filter out illegal moves
	var legal_moves := []
	for move in moves:
		__make_move(move)
		if !__king_attacked(us):
			legal_moves.append(move)
		__undo_move()

	return legal_moves


# convert a move from 0x88 coordinates to Standard Algebraic Notation
# (SAN)
#
# @param {boolean} sloppy Use the sloppy SAN generator to work around over
# disambiguation bugs in Fritz and Chessbase.  See below:
#
# r1bqkbnr/ppp2ppp/2n5/1B1pP3/4P3/8/PPPP2PP/RNBQK1NR b KQkq - 2 4
# 4. ... Nge7 is overly disambiguated because the knight on c6 is pinned
# 4. ... Ne7 is technically the valid SAN
func __move_to_san(move, moves := __generate_moves({legal = true}), annotations := true) -> String:
	var output := ""

	if move.flags & BITS.KSIDE_CASTLE:
		output = "O-O"
	elif move.flags & BITS.QSIDE_CASTLE:
		output = "O-O-O"
	else:
		if move.piece != PAWN:
			var disambiguator := get_disambiguator(move, moves)
			output += move.piece.to_upper() + disambiguator

		if move.flags & (BITS.CAPTURE | BITS.EP_CAPTURE):
			if move.piece == PAWN:
				output += algebraic(move.from)[0]
			output += "x"

		output += algebraic(move.to)

		if move.flags & BITS.PROMOTION:
			output += "=" + move.promotion.to_upper()
	if annotations:
		__make_move(move)
		if in_check():
			if in_checkmate():
				output += "#"
			else:
				output += "+"
		__undo_move()
	return output


func __attacked(color: String, square: int):
	var i := 0

	while i < SQUARE_MAP.h1:
		i += 1
		# did we run off the end of the board
		if i & 0x88:
			i += 7
			continue

		# if empty square or wrong color
		if board[i] == null || board[i].color != color:
			continue

		var piece: Dictionary = board[i]
		var difference := i - square
		var index := difference + 119

		if ATTACKS[index] & (1 << SHIFTS[piece.type]):
			if piece.type == PAWN:
				if difference > 0:
					if piece.color == WHITE:
						return true
				else:
					if piece.color == BLACK:
						return true
				continue

			# if the piece is a knight or a king
			if piece.type == "n" || piece.type == "k":
				return true

			var offset := RAYS[index]
			var j := i + offset

			var blocked := false
			while j != square:
				if board[j] != null:
					blocked = true
					break
				j += offset

			if !blocked:
				return true
	return false


func __king_attacked(color):
	return __attacked(__swap_color(color), kings[color])


func in_check():
	return __king_attacked(turn)


func in_checkmate():
	return in_check() && __generate_moves().size() == 0


func in_stalemate():
	return !in_check() && __generate_moves().size() == 0


func insufficient_material():
	var pieces := {b = 0, k = 0, r = 0, q = 0, n = 0, p = 0}
	var bishops := []
	var num_pieces := 0
	var sq_color := 0
	var i := 0
	while i < SQUARE_MAP.h1:
		i += 1

		sq_color = (sq_color + 1) % 2
		if i & 0x88:
			i += 7
			continue

		var piece = board[i]
		if piece:
			pieces[piece.type] += 1
			if piece.type == BISHOP:
				bishops.append(sq_color)
			num_pieces += 1
	# k vs k
	if num_pieces == 2:
		return true
	elif num_pieces == 3 && (pieces[BISHOP] == 1 || pieces[KNIGHT] == 1):
		# k vs. kn .... or .... k vs. kb
		return true
	elif num_pieces == pieces[BISHOP] + 2:
		# kb vs. kb where any number of bishops are all on the same color
		var sum := 0
		var lent := bishops.size()
		for b in bishops:
			sum += b
		if sum == 0 || sum == lent:  # check if on same color
			return true
	return false


func in_threefold_repetition():
	# TODO: while this func is fine for casual use, a better
	# implementation would use a Zobrist key (instead of FEN). the
	# Zobrist key would be maintained in the __make_move/__undo_move funcs,
	# avoiding the costly funcs that we do below.
	var moves := []
	var positions := {}
	var repetition := false

	while true:
		var move: Dictionary = __undo_move()
		if !move:
			break
		moves.append(move)

	while true:
		# remove the last two fields in the FEN string, they're not needed
		# when checking for draw by rep
		if !repetition:
			var fen := PoolStringArray(Array(fen().split(" ")).slice(0, 3)).join(" ")

			# has the position occurred three or more times
			positions[fen] = positions[fen] + 1 if fen in positions else 1
			if positions[fen] >= 3:
				repetition = true

		if !moves.size():
			break
		__make_move(moves.pop_back())

	return repetition


func __push(move):
	__history.append(
		{
			move = move,
			kings = {b = kings.b, w = kings.w},
			turn = turn,
			castling = {b = castling.b, w = castling.w},
			ep_square = ep_square,
			half_moves = half_moves,
			fullmoves = fullmoves,
		}
	)


func __make_move(move: Dictionary):
	var us := turn
	var them := __swap_color(us)
	__push(move)

	board[move.to] = board[move.from]
	board[move.from] = null

	# if ep capture, remove the captured pawn
	if move.flags & BITS.EP_CAPTURE:
		if turn == BLACK:
			board[move.to - 16] = null
		else:
			board[move.to + 16] = null

	# if pawn promotion, replace with new piece
	if move.flags & BITS.PROMOTION:
		board[move.to] = {type = move.promotion, color = us}

	# if we moved the king
	if board[move.to].type == KING:
		kings[board[move.to].color] = move.to

		# if we castled, move the rook next to the king
		if move.flags & BITS.KSIDE_CASTLE:
			var castling_to: int = move.to - 1
			var castling_from: int = move.to + 1
			board[castling_to] = board[castling_from]
			board[castling_from] = null
		elif move.flags & BITS.QSIDE_CASTLE:
			var castling_to: int = move.to + 1
			var castling_from: int = move.to - 2
			board[castling_to] = board[castling_from]
			board[castling_from] = null

		# turn off castling
		castling[us] = 0

	# turn off castling if we move a rook
	if castling[us]:
		for rook in ROOKS[us]:
			if move.from == rook.square && castling[us] & rook.flag:
				castling[us] ^= rook.flag
				break
	# turn off castling if we capture a rook
	if castling[them]:
		for rook in ROOKS[them]:
			if move.to == rook.square && castling[them] & rook.flag:
				castling[them] ^= rook.flag
				break

	# if big pawn move, update the en passant square
	if move.flags & BITS.BIG_PAWN:
		if turn == "b":
			ep_square = move.to - 16
		else:
			ep_square = move.to + 16
	else:
		ep_square = EMPTY

	# reset the 50 move counter if a pawn is moved or a piece is captured
	if move.piece == PAWN:
		half_moves = 0
	elif move.flags & (BITS.CAPTURE | BITS.EP_CAPTURE):
		half_moves = 0
	else:
		half_moves += 1

	if turn == BLACK:
		fullmoves += 1
	turn = __swap_color(turn)


func __undo_move() -> Dictionary:
	var old = __history.pop_back()
	if old == null:
		return {}

	var move: Dictionary = old.move
	kings = old.kings
	turn = old.turn
	if typeof(old.castling.w) != TYPE_INT || typeof(old.castling.b) != TYPE_INT:
		breakpoint
	castling = old.castling
	ep_square = old.ep_square
	half_moves = old.half_moves
	fullmoves = old.fullmoves

	var us := turn
	var them := __swap_color(turn)

	board[move.from] = board[move.to]
	board[move.from].type = move.piece  # to undo any promotions
	board[move.to] = null

	if move.flags & BITS.CAPTURE:
		board[move.to] = {type = move.captured, color = them}
	elif move.flags & BITS.EP_CAPTURE:
		var index
		if us == BLACK:
			index = move.to - 16
		else:
			index = move.to + 16
		board[index] = {type = PAWN, color = them}

	if move.flags & (BITS.KSIDE_CASTLE | BITS.QSIDE_CASTLE):
		var castling_to
		var castling_from
		if move.flags & BITS.KSIDE_CASTLE:
			castling_to = move.to + 1
			castling_from = move.to - 1
		elif move.flags & BITS.QSIDE_CASTLE:
			castling_to = move.to - 2
			castling_from = move.to + 1

		board[castling_to] = board[castling_from]
		board[castling_from] = null

	return move


# convert a move from Standard Algebraic Notation (SAN) to 0x88 coordinates
func __move_from_san(move, sloppy := false) -> Dictionary:
	# strip off any move decorations: e.g Nf3+?! becomes Nf3
	var clean_move := stripped_san(move)

	var overly_disambiguated := false
	var piece
	var from
	var to
	var promotion
	var matches

	# the move parsers is a 2-step state
	for parser in range(2):
		if parser == PARSER_SLOPPY:
			# only run the sloppy parse if explicitly requested
			if !sloppy:
				return {}

			# The sloppy parser allows the user to parse non-standard chess
			# notations. This parser is opt-in (by specifying the
			# '{ sloppy: true }' setting) and is only run after the Standard
			# Algebraic Notation (SAN) parser has failed.
			#
			# When running the sloppy parser, we'll run a regex to grab the piece,
			# the to/from square, and an optional promotion piece. This regex will
			# parse common non-standard notation like: Pe2-e4, Rc1c4, Qf3xf7,
			# f7f8q, b1c3
			#
			# NOTE: Some positions and moves may be ambiguous when using the
			# sloppy parser. For example, in this position:
			# 6k1/8/8/B7/8/8/8/BN4K1 w - - 0 1, the move b1c3 may be interpreted
			# as Nc3 or B1c3 (a disambiguated bishop move). In these cases, the
			# sloppy parser will default to the most most basic interpretation
			# (which is b1c3 parsing to Nc3).

			var move_regex := RegEx.new()
			move_regex.compile("([pnbrqkPNBRQK])?([a-h][1-8])x?-?([a-h][1-8])([qrbnQRBN])")

			# The [a-h]?[1-8]? portion of the regex below handles moves that may
			# be overly disambiguated (e.g. Nge7 is unnecessary and non-standard
			# when there is one legal knight move to e7). In this case, the value
			# of 'from' variable will be a rank or file, not a square.
			var fallback := RegEx.new()
			fallback.compile("([pnbrqkPNBRQK])?([a-h]?[1-8]?)x?-?([a-h][1-8])([qrbnQRBN])?")

			var result := move_regex.search(clean_move)
			if result:
				matches = result.strings
				piece = matches[1]
				from = matches[2]
				to = matches[3]
				promotion = matches[4]
			else:
				var _result := fallback.search(clean_move)

				if _result:
					matches = _result.strings
					piece = matches[1]
					from = matches[2]
					to = matches[3]
					promotion = matches[4]

			if from.length() == 1:
				overly_disambiguated = true

		var piece_type := infer_piece_type(clean_move)
		var moves := __generate_moves(
			{
				legal = true,
				piece = piece if piece else piece_type,
			}
		)
		for move in moves:
			match parser:
				PARSER_STRICT:
					var m := stripped_san(__move_to_san(move, moves, false))
					if clean_move == m:
						return move
					continue
				PARSER_SLOPPY:
					if matches:
						# hand-compare move properties with the results from our sloppy regex
						if (
							(!piece || piece.to_lower() == move.piece)
							&& from in SQUARE_MAP
							&& to in SQUARE_MAP
							&& SQUARE_MAP[from] == move.from
							&& SQUARE_MAP[to] == move.to
							&& (!promotion || promotion.to_lower() == move.promotion)
						):
							return move
						elif overly_disambiguated:
							# SPECIAL CASE: we parsed a move string that may have an
							# unneeded rank/file disambiguator (e.g. Nge7).  The 'from'
							# variable will be validated
							var square := algebraic(move.from)
							if (
								(!piece || piece.to_lower() == move.piece)
								&& to in SQUARE_MAP
								&& SQUARE_MAP[to] == move.to
								&& (from == square[0] || from == square[1])
								&& (!promotion || promotion.to_lower() == move.promotion)
							):
								return move
	return {}


func __make_pretty(ugly_move: Dictionary) -> Dictionary:
	var move := ugly_move.duplicate()
	move.san = __move_to_san(move, __generate_moves({legal = true}))
	move.to = algebraic(move.to)
	move.from = algebraic(move.from)

	var flags := ""

	for flag in BITS:
		if BITS[flag] & move.flags:
			flags += FLAGS[flag]

	move.flags = flags
	return move


#*****************************************************************************
#* DEBUGGING UTILITIES
#****************************************************************************/
func perft(depth: int) -> int:
	var moves := __generate_moves({legal = false})
	var nodes := 0
	var color := turn
	for move in moves:
		__make_move(move)
		if !__king_attacked(color):
			if depth - 1 > 0:
				var child_nodes := perft(depth - 1)
				nodes += child_nodes
			else:
				nodes += 1
		__undo_move()

	return nodes


#***************************************************************************
#* PUBLIC API
#***************************************************************************


func in_draw():
	return half_moves >= 50 || in_stalemate() || insufficient_material() || in_threefold_repetition()


func game_over():
	return (
		half_moves >= 50
		|| in_checkmate()
		|| in_stalemate()
		|| insufficient_material()
		|| in_threefold_repetition()
	)


# lists the possible legal moves.
func moves(options := {}):
	# The internal representation of a chess move is in 0x88 format, and
	# not meant to be human-readable.  The code below converts the 0x88
	# square coordinates to algebraic coordinates.  It also prunes an
	# unnecessary move keys resulting from a verbose call.

	var ugly_moves := __generate_moves(options)
	var moves := []
	for ugly_move in ugly_moves:
		# does the user want a full move object (most likely not), or just
		# SAN
		if "verbose" in options && options.verbose:
			moves.append(__make_pretty(ugly_move))
		else:
			moves.append(__move_to_san(ugly_move, __generate_moves({legal = true})))
	return moves


# warning-ignore:function_conflicts_variable
# returns a 2d matrix of the board.
func board():
	var output := []
	var row := []
	var i := 0
	while i < SQUARE_MAP.h1:
		i += 1
		if board[i] == null:
			row.append(null)
		else:
			row.append(
				{
					square = algebraic(i),
					type = board[i].type,
					color = board[i].color,
				}
			)
		if (i + 1) & 0x88:
			output.append(row)
			row = []
			i += 8
	return output


func pgn() -> String:
	# using the specification from http://www.chessclub.com/help/PGN-spec
	# pop all of __history onto reversed_history
	var reversed_history := []
	while !__history.empty():
		reversed_history.append(__undo_move())
	var moves: PoolStringArray = []
	var move_string := ""
	# build the list of moves.  a move_string looks like: "3. e3 e6"
	while reversed_history.size() > 0:
		var move: Dictionary = reversed_history.pop_back()

		# if the position started with black to move, start PGN with 1. ...
		if !__history.size() and move.color == "b":
			move_string = "%s ..." % fullmoves
		elif move.color == "w":
			if move_string.length() > 0:
				moves.append(move_string)
			move_string = "%s." % fullmoves

		move_string += " %s" % __move_to_san(move, __generate_moves({legal = true}))
		__make_move(move)

	# __history should be back to what it was before we started generating PGN,
	# so join together moves
	return moves.join(" ")


func load_pgn(pgn, options := {}) -> int:  # FIXME: mildly broken. move generator for a8 cannot get a4, for some reason.
	# allow the user to specify the sloppy move parser to work around over
	# disambiguation bugs in Fritz and Chessbase
	var sloppy: bool = options.sloppy if "sloppy" in options else false

	var parsed: Dictionary = Pgn.parse(pgn)

	# Put the board in the starting position
	reset()

	var fen := ""

	for key in parsed.headers:
		# check to see user is including fen (possibly with wrong tag case)
		if key.to_lower() == "fen":
			fen = parsed.headers[key]

	# sloppy parser should attempt to load a fen tag, even if it's
	# the wrong case and doesn't include a corresponding [SetUp "1"] tag */
	if sloppy and fen:
		if !load_fen(fen):
			return ERR_INVALID_DATA
	else:
		# strict parser - load_fen the starting position indicated by [Setup '1']
		# and [FEN position]
		if "SetUp" in parsed.headers and parsed.headers["SetUp"] == "1":
			if !("FEN" in parsed.headers && load_fen(parsed.headers["FEN"])):
				return ERR_INVALID_DATA

	var moves: Array = parsed.moves
	var move := {}
	var result := ""
	for mov in moves:
		move = __move_from_san(mov, sloppy)
		if !move:
			# was the move an end of game marker
			if TERMINATION_MARKERS.find(mov) != -1:
				result = mov
			else:
				return ERR_INVALID_DATA
		else:
			# reset the end of game marker if making a valid move
			result = ""
			__make_move(move)
	# Per section 8.2.6 of the PGN spec, the Result tag pair must match
	# match the termination marker. Only do this when headers are present,
	# but the result tag is missing
	if result && parsed.headers.size() && !parsed.header["Result"]:
		moves.append(result)
	return OK


# The move func can be called with in the following parameters:
#
# .move('Nxb7')      <- where 'move' is a case-sensitive SAN string
#
# .move({ from: 'h7', to :'h8', promotion: 'q'})  <- where the 'move' is a move obj
func move(move, sloppy := false) -> Dictionary:
	var move_obj = null

	if typeof(move) == TYPE_STRING:
		move_obj = __move_from_san(move, sloppy)
	elif typeof(move) == TYPE_DICTIONARY:
		var moves := __generate_moves()

		# uglify move
		for m in moves:
			if (
				move.from == algebraic(m.from)
				&& move.to == algebraic(m.to)
				&& (!("promotion" in m) || move.promotion == m.promotion)
			):
				move_obj = m
				break

	# failed to find move
	if !move_obj:
		return {}

	# need to make a copy of move because we can't generate SAN after the
	# move is made
	var pretty_move := __make_pretty(move_obj)

	__make_move(move_obj)

	return pretty_move


func undo() -> Dictionary:
	var move := __undo_move()
	return __make_pretty(move) if move else {}


func ascii() -> String:
	var s := "   +------------------------+\n"
	var i := 0
	while i < SQUARE_MAP.h1 + 1:
		# display the rank
		if file(i) == 0:
			s += " " + "87654321"[rank(i)] + " |"

		# empty piece
		if board[i] == null:
			s += " . "
		else:
			var piece: String = board[i].type
			var color: String = board[i].color
			var symbol := piece.to_upper() if color == WHITE else piece.to_lower()
			s += " " + symbol + " "
		if (i + 1) & 0x88:
			s += "|\n"
			i += 8
		i += 1
	s += "   +------------------------+\n"
	s += "     a  b  c  d  e  f  g  h"

	return s


static func square_color(square):
	if square in SQUARE_MAP:
		var sq_0x88: int = SQUARE_MAP[square]
		return "light" if (rank(sq_0x88) + file(sq_0x88)) % 2 == 0 else "dark"
	return null


func history(verbose := false) -> Array:
	var reversed_history := []
	var move_history := []

	while __history.size() > 0:
		reversed_history.append(__undo_move())

	while reversed_history.size() > 0:
		var move: Dictionary = reversed_history.pop_back()
		if verbose:
			move_history.append(__make_pretty(move))
		else:
			move_history.append(__move_to_san(move, __generate_moves({legal = true})))
		__make_move(move)

	return move_history

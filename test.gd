extends Node


class TestSan:
	extends SanParser

	func assert_castle(string: String, s):
		var m = parse(string)
		assert(m.move_kind.type == Move.MoveKind.CASTLE)
		assert(m.move_kind.data == s)
		assert(m.piece == KING)
		assert(m.promotion == -1)
		assert(m.check_type == Move.CHECKTYPES.NONE)
		assert(m.is_capture == false)

	func assert_move(mv: String, start: Vector2, dest: Vector2, piece: int) -> void:
		assert_all(parse(mv), PoolVector2Array([start, dest]), piece, false)

	func assert_capture(mv: String, start: Vector2, dest: Vector2, piece: int) -> void:
		assert_all(parse(mv), PoolVector2Array([start, dest]), piece, true)

	func assert_all(mv: Move, vectors: PoolVector2Array, piece: int, capture: bool, promote = -1) -> void:
		assert(mv.move_kind.type == Move.MoveKind.NORMAL)
		assert([mv.move_kind.data == vectors, mv.piece == piece, mv.is_capture == capture].min())
		if promote != -1:
			assert(mv.promotion == promote)

	func test_algebraic_conversion():
		assert(Utils.from_algebraic(Utils.to_algebraic(Vector2.ZERO)) == Vector2.ZERO)
		assert(Utils.from_algebraic(Utils.to_algebraic(Vector2.ONE)) == Vector2.ONE)
		assert(pos("a", "9") == Utils.from_algebraic("a9"))
		assert(Utils.col_pos("h") == 7)
		assert(Utils.row_pos("1") == 7)

	func test_castle_short():
		assert_castle("O-O", Move.MoveKind.CASTLETYPES.KING_SIDE)

	func test_castle_long():
		assert_castle("O-O-O", Move.MoveKind.CASTLETYPES.QUEEN_SIDE)

	func test_pawn():
		assert_move("e4", UNKNOWN_POS, Vector2(4, 4), PAWN)

	func test_pawn_long():
		assert_move("e2e4", Vector2(4, 6), Vector2(4, 4), PAWN)

	func test_piece():
		assert_move("Qe4", UNKNOWN_POS, Vector2(4, 4), QUEEN)

	func test_piece_file():
		assert_move("Qbe4", Vector2(1, -1), Vector2(4, 4), QUEEN)

	func test_piece_rank():
		assert_move("Q1e4", Vector2(-1, 7), Vector2(4, 4), QUEEN)

	func test_piece_long():
		assert_move("Qb1e4", Vector2(1, 7), Vector2(4, 4), QUEEN)

	func test_pawn_capture():
		assert_capture("exd4", Vector2(4, -1), Vector2(3, 4), PAWN)

	func test_pawn_capture_promotion():
		assert_all(parse("exd8=Q"), PoolVector2Array([Vector2(4, -1), Vector2(3, 0)]), PAWN, true, QUEEN)

	func test_pawn_capture_long():
		assert_capture("e3xd4", Vector2(4, 5), Vector2(3, 4), PAWN)

	func test_piece_capture():
		assert_capture("R1xh3", Vector2(-1, 7), Vector2(7, 5), ROOK)

	func test_piece_capture_file():
		assert_capture("Rexh3", Vector2(4, -1), Vector2(7, 5), ROOK)

	func test_piece_capture_long():
		assert_capture("Re3xh3", Vector2(4, 5), Vector2(7, 5), ROOK)

	func test_pawn_promotion():
		assert_all(parse("d8=Q"), PoolVector2Array([UNKNOWN_POS, Vector2(3, 0)]), PAWN, QUEEN)

	func test_compile():
		var s = Move.new(PAWN, [Vector2(4, -1), Vector2(3, 0)])
		s.promotion = QUEEN
		s.check_type = Move.CHECKTYPES.CHECK
		s.is_capture = true
		var result = s.compile()
		assert(result == "exd8=Q+")
		assert((SanParse.parse("e4").compile()) == "e4")

	func _init():
		test_algebraic_conversion()
		test_castle_short()
		test_castle_long()
		test_pawn()
		test_pawn_long()
		test_piece()
		test_piece_file()
		test_piece_rank()
		test_piece_long()
		test_pawn_capture()
		test_pawn_capture_promotion()
		test_pawn_capture_long()
		test_piece_capture()
		test_piece_capture_file()
		test_piece_capture_long()
		test_pawn_promotion()
		test_compile()


func _ready():
	if Debug.is_debug():
		TestSan.new()

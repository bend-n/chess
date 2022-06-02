class_name Move
extends Resource

enum CHECKTYPES { NONE, CHECK, CHECKMATE }
var generated_from := ""
var piece := -1
var move_kind: MoveKind
var promotion := -1
# var annotation := "" # later
var check_type := 0
var is_capture := false


func _init(newpiece: int, newmove, capture := false) -> void:
	piece = newpiece
	is_capture = capture
	move_kind = MoveKind.new(newmove)


static func castle_type(type: String) -> int:
	return MoveKind.CASTLETYPES.QUEEN_SIDE if type == "O-O-O" else MoveKind.CASTLETYPES.KING_SIDE


func set_check_type(type: String) -> void:
	match type:
		"+":
			check_type = CHECKTYPES.CHECK
		"#":
			check_type = CHECKTYPES.CHECKMATE
		_:
			check_type = CHECKTYPES.NONE


func compile() -> String:  # compiles the structure to a san
	var res := ""
	match move_kind.type:
		MoveKind.CASTLE:
			res += move_kind.to_str()
		MoveKind.NORMAL:
			res += Utils.to_str(piece)
			res += Utils.to_algebraic(move_kind.data[0])
			res += "x" if is_capture else ""
			res += Utils.to_algebraic(move_kind.data[1])
			res += "=" + Utils.to_str(promotion) if promotion != -1 else ""
			match check_type:
				CHECKTYPES.CHECK:
					res += "+"
				CHECKTYPES.CHECKMATE:
					res += "#"
	return res.strip_edges()


## tests
#	print(Utils.to_algebraic(make_long(SanParse.parse("e4").move_kind.data, false, SanParser.PAWN)[0]) == "e2")
# 	print(Utils.to_algebraic(make_long(SanParse.parse("Nbc3").move_kind.data, false, SanParser.KNIGHT)[0]) == "b1")
# 	print(Utils.to_algebraic(make_long(SanParse.parse("N1c3").move_kind.data, false, SanParser.KNIGHT)[0]) == "b1")


# 	print(Utils.to_algebraic(make_long(SanParse.parse("exe4").move_kind.data, false, SanParser.PAWN)[0]) == "e2")
# 	print(Utils.to_algebraic(make_long(SanParse.parse("Nbxc3").move_kind.data, false, SanParser.KNIGHT)[0]) == "b1")
# 	print(Utils.to_algebraic(make_long(SanParse.parse("N1xc3").move_kind.data, false, SanParser.KNIGHT)[0]) == "b1")
### fix short san
func make_long():
	var newvecs: PoolVector2Array = []

	var vectors = move_kind.data

	if Piece.is_on_board(vectors[0]):  # [0] is the only one with -1(s) possible
		return vectors

	if is_capture:
		newvecs.append(long_helper(vectors[0], true, false, vectors[1]))
	else:
		newvecs.append(long_helper(vectors[0], false, true, vectors[1]))

	if newvecs.empty():
		Log.error("cruddlesticks")
		return
	newvecs.append(vectors[1])

	move_kind.data = newvecs


func long_helper(vec: Vector2, attack: bool, move: bool, touch: Vector2):
	if vec.y == -1 and vec.x != -1:
		for y in range(8):
			var spot = Piece.at_pos(Vector2(vec.x, y))
			if Utils.spotispiece(piece, spot) and spot.can_touch(touch, attack, move):
				return Vector2(vec.x, y)
	elif vec.x == -1 and vec.y != -1:
		for x in range(8):
			var spot = Piece.at_pos(Vector2(x, vec.y))
			if Utils.spotispiece(piece, spot) and spot.can_touch(touch, attack, move):
				return Vector2(x, vec.y)
	elif vec == Vector2(-1, -1):
		for x in range(8):
			for y in range(8):
				var spot = Piece.at_pos(Vector2(x, y))
				if Utils.spotispiece(piece, spot) and spot.can_touch(touch, attack, move):
					return Vector2(x, y)


class MoveKind:
	extends Resource
	enum CASTLETYPES { NONE, QUEEN_SIDE, KING_SIDE }
	enum { NONE, NORMAL, CASTLE }
	var type := 0
	var data  # string OR array

	func _init(something):
		if typeof(something) == TYPE_ARRAY and len(something) == 2:
			type = NORMAL
			data = PoolVector2Array(something)
		elif typeof(something) == TYPE_INT:
			type = CASTLE
			data = something
		else:
			assert(false)

	func to_str() -> String:
		return "O-O-O" if data == CASTLETYPES.QUEEN_SIDE else "O-O"

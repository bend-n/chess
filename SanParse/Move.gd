class_name Move
extends Resource

enum CASTLETYPES { NONE, QUEEN_SIDE, KING_SIDE }
enum CHECKTYPES { NONE, CHECK, CHECKMATE }
var generated_from := ""
var piece := 0
var move_kind: MoveKind
var promotion := 0
# var annotation := "" # later
var check_type := 0
var is_capture := false


func _init(newpiece: int, newmove, capture := false) -> void:
	piece = newpiece
	is_capture = capture
	move_kind = MoveKind.new(newmove)


static func castle_type(type: String) -> int:
	return CASTLETYPES.QUEEN_SIDE if type == "O-O-O" else CASTLETYPES.KING_SIDE


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
			res = res + "x" if is_capture else res
			res += Utils.to_algebraic(move_kind.data[1])
			res = res + "=" + Utils.to_str(promotion) if promotion != -1 else res
			match check_type:
				CHECKTYPES.CHECK:
					res += "+"
				CHECKTYPES.CHECKMATE:
					res += "#"
				_:
					pass
	return res


class MoveKind:
	extends Resource
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
		return "O-O-O" if data == CASTLETYPES.QUEENSIDE else "O-O"

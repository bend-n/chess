extends Node
class_name SanParser

const end := "(\\+|\\#)?(\\?\\?|\\?|\\?!|!|!!)?$"  # annotation

var regexs := {
	"pawn_move": compile("^([a-h])([1-8])"),
	"long_pawn_move": compile("^([a-h])([1-8])([a-h])([1-8])"),  # long-san
	"piece_movement": compile("^([KQBNR])([a-h])([1-8])"),
	"specific_row_piece_movement": compile("^([KQBNR])([0-9])([a-h])([1-8])"),
	"specific_column_piece_movement": compile("^([KQBNR])([a-h])([a-h])([1-8])"),
	"long_piece_movement": compile("^([KQBNR])([a-h])([0-9])([a-h])([1-8])"),
	"pawn_capture": compile("^([a-h])x([a-h])([1-8])(?:=?([KQBNR]))?"),
	"long_pawn_capture": compile("^([a-h])([1-8])x([a-h])([1-8])(?:=?([KQBNR]))?"),
	"piece_capture": compile("^([KQBNR])x([a-h])([1-8])"),
	"specific_column_piece_capture": compile("^([KQBNR])([a-h])x([a-h])([1-8])"),
	"specific_row_piece_capture": compile("^([KQBNR])([0-9])x([a-h])([1-8])"),
	"long_piece_capture": compile("^([KQBNR])([a-h])([0-9])x([a-h])([1-8])"),
	"pawn_promotion": compile("^([a-h])([1-8])=?([KQBNR])"),
	"long_pawn_promotion": compile("^([a-h])([1-8])([a-h])([1-8])=?([KQBNR])"),
	"castling": compile("^(O-O-O|O-O)"),
}


static func pos(col: String, row: String) -> Vector2:
	return Utils.from_algebraic(col + row)


const UNKNOWN_POS = Vector2(-1, -1)
enum { PAWN, KNIGHT, BISHOP, ROOK, QUEEN, KING }


static func from_str(string: String) -> int:
	var find = " NBRQK".find(string)
	if find != -1:
		return find
	else:
		return "PNBRQK".find(string)


func compile(regxstr: String, app_end := true) -> RegEx:  #app_end because append end get it
	var reg = RegEx.new()
	reg.compile(regxstr + end if app_end else regxstr)
	return reg


func parse(san: String) -> Move:
	var mv = regexmatch(san)
	mv.generated_from = san  # for debugging i just moved the thing over so i can do this
	return mv


func regexmatch(san: String) -> Move:
	var re: RegExMatch = regexs.pawn_move.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(PAWN, [UNKNOWN_POS, pos(cap[1], cap[2])]).set_check_type(cap[3])
		return mov

	re = regexs.long_pawn_move.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(PAWN, [pos(cap[1], cap[2]), pos(cap[3], cap[4])]).set_check_type(cap[5])
		return mov

	re = regexs.piece_movement.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(from_str(cap[1]), [UNKNOWN_POS, pos(cap[2], cap[3])])
		mov.set_check_type(cap[4])
		return mov

	re = regexs.specific_row_piece_movement.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(
			from_str(cap[1]), [Vector2(-1, Utils.row_pos(cap[2])), pos(cap[3], cap[4])]
		)
		mov.set_check_type(cap[5])
		return mov

	re = regexs.specific_column_piece_movement.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(
			from_str(cap[1]), [Vector2(Utils.col_pos(cap[2]), -1), pos(cap[3], cap[4])]
		)
		mov.set_check_type(cap[5])
		return mov

	re = regexs.long_piece_movement.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(from_str(cap[1]), [pos(cap[2], cap[3]), pos(cap[4], cap[5])])
		mov.set_check_type(cap[6])
		return mov

	re = regexs.pawn_capture.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(PAWN, [Vector2(Utils.col_pos(cap[1]), -1), pos(cap[2], cap[3])], true)
		mov.promotion = from_str(cap[4])
		mov.set_check_type(cap[5])
		return mov

	re = regexs.long_pawn_capture.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(PAWN, [pos(cap[1], cap[2]), pos(cap[3], cap[4])], true)
		mov.promotion = from_str(cap[5])
		mov.set_check_type(cap[6])
		return mov

	re = regexs.piece_capture.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(from_str(cap[1]), [UNKNOWN_POS, pos(cap[2], cap[3])], true)
		mov.set_check_type(cap[4])
		return mov

	re = regexs.specific_column_piece_capture.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(
			from_str(cap[1]), [Vector2(Utils.col_pos(cap[2]), -1), pos(cap[3], cap[4])], true
		)
		mov.set_check_type(cap[5])
		return mov

	re = regexs.specific_row_piece_capture.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(
			from_str(cap[1]), [Vector2(-1, Utils.row_pos(cap[2])), pos(cap[3], cap[4])], true
		)
		mov.set_check_type(cap[5])
		return mov

	re = regexs.long_piece_capture.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(from_str(cap[1]), [pos(cap[2], cap[3]), pos(cap[4], cap[5])], true)
		mov.set_check_type(cap[6])
		return mov

	re = regexs.pawn_promotion.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(PAWN, [UNKNOWN_POS, pos(cap[1], cap[2])], true)
		mov.promotion = from_str(cap[3])
		mov.set_check_type(cap[4])
		return mov

	re = regexs.long_pawn_promotion.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(PAWN, [pos(cap[1], cap[2]), pos(cap[3], cap[4])], true)
		mov.promotion = from_str(cap[5])
		mov.set_check_type(cap[6])
		return mov

	re = regexs.castling.search(san)
	if re:
		var cap = re.strings
		var mov = Move.new(KING, Move.castle_type(cap[1]))
		mov.set_check_type(cap[2])
		return mov

	push_error("regex exhausted: no matches(%s)" % san)

	return null

extends Node
class_name FEN


func parse(fen: String) -> Dictionary:
	var reg = RegEx.new()
	reg.compile(
		"^(?<pieces>([pnbrqkPNBRQK1-8]{1,8}\\/?){8})\\s+(?<turn>b|w)\\s+(?<castling>-|K?Q?k?q)\\s+(?<enpassant>-|[a-h][3-6])\\s+(?<halfmove>\\d+)\\s+(?<fullmove>\\d+)\\s*$"
	)
	var res = reg.search(fen)
	if res:
		var mat: Array = []
		var rows = res.strings[res.names.pieces].split("/")
		for row in rows:
			var append_row: Array = []
			for col in row:
				if int(col) != 0:
					for _i in range(int(col)):
						append_row.append("")
				else:
					append_row.append(col)
			mat.append(append_row)
		var fenobj = {
			"mat": mat,
			"turn": res.strings[res.names.turn] == "w",
			"castling": res.strings[res.names.castling],
			"enpassant": res.strings[res.names.enpassant],
			"halfmove": int(res.strings[res.names.halfmove]),
			"fullmove": int(res.strings[res.names.fullmove])
		}
		return fenobj
	else:
		Log.err("bad fen")
		return {}


func get_fen() -> String:
	var pieces := ""
	for rank in range(8):
		var empty := 0
		for file in range(8):
			var spot: Piece = Globals.grid.matrix[rank][file]
			if spot == null:
				empty += 1
				if len(pieces) > 0 and str(empty - 1) == pieces[-1]:
					pieces[-1] = str(empty)
				else:
					pieces += str(empty)
			else:
				pieces += (
					spot.shortname[0].to_upper()
					if spot.white
					else spot.shortname[0].to_lower()
				)
				empty = 0
		if rank != 7:
			pieces += "/"
	# handle castling checks
	var whitecastling := PoolStringArray(Globals.white_king.castleing(true)).join("")
	var blackcastling := PoolStringArray(Globals.black_king.castleing(true)).join("")
	var castlingrights := ""
	if blackcastling and whitecastling:
		castlingrights = whitecastling.to_upper() + blackcastling.to_lower()
	else:
		castlingrights = "-"
		# castling rights are slightly janke

	var enpassants := ""
	for pawn in Globals.pawns:
		if pawn.just_double_stepped and pawn.just_set:
			enpassants = Utils.to_algebraic(pawn.real_position + (Vector2.DOWN * pawn.whiteint))
			break
	return (
		"%s %s %s %s %s %s"
		% [
			pieces,
			"w" if Globals.turn else "b",
			castlingrights,
			enpassants if enpassants else "-",
			Globals.halfmove,
			Globals.fullmove,
		]
	)  # pos  # turn  # castling  # enpassant  # halfmove  # fullmove

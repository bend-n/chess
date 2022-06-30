extends Node
class_name FEN

var reg = Utils.compile(
	"^(?<pieces>([pnbrqkPNBRQK1-8]{1,8}/?){8})\\s+(?<turn>b|w)\\s+(?<castling>-|K?Q?k?q?)\\s+(?<enpassant>-|[a-h][3-6])\\s+(?<halfmove>\\d+)\\s+(?<fullmove>\\d+)"
)


func parse(fen: String) -> Dictionary:
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
			"turn": res.strings[res.names.turn],
			"castling": res.strings[res.names.castling],
			"enpassant": res.strings[res.names.enpassant],
			"halfmove": int(res.strings[res.names.halfmove]),
			"fullmove": int(res.strings[res.names.fullmove])
		}
		return fenobj
	else:
		Log.err("bad fen")
		return {}

extends Node

signal newmove(move)
signal newfen(fen)

var turn_moves: PoolStringArray = []
var turns_moves: PoolStringArray = []

var counter := 0


func _ready() -> void:
	Events.connect("turn_over", self, "_on_turn_over")


func is_pawn(inode) -> bool:
	return inode is Pawn


func add_move(move) -> void:
	if turn_moves.size() == 0:
		turn_moves.append(str(Globals.fullmove) + ". " + move)
	else:
		turn_moves.append(move)
	emit_signal("newmove", move)


func reset_vars() -> void:
	turn_moves.resize(0)
	turns_moves.resize(0)
	counter = 0


func to_algebraic(real_position) -> String:
	return char(65 + (real_position.x)).to_lower() + str(8 - real_position.y)


func from_algebraic(algebraic_position: String) -> Vector2:
	return Vector2(ord(algebraic_position[0]) - ord("a"), 8 - int(algebraic_position[1]))


func get_node_name(node) -> Array:
	if is_pawn(node):
		return ["♙", "p"] if node.white else ["♟", "p"]
	elif node is King:
		return ["♔", "K"] if node.white else ["♚", "K"]
	elif node is Queen:
		return ["♕", "Q"] if node.white else ["♛", "Q"]
	elif node is Rook:
		return ["♖", "R"] if node.white else ["♜", "R"]
	elif node is Bishop:
		return ["♗", "B"] if node.white else ["♝", "B"]
	elif node is Knight:
		return ["♘", "N"] if node.white else ["♞", "N"]
	else:
		return ["", ""]


func walk_dir(path = "res://assets/pieces") -> PoolStringArray:  # walk the directory, finding the asset packs
	var folders: PoolStringArray = []  # init the folders
	var dir := Directory.new()  # init the directory
	if dir.open(path) == OK:  # open the directory
		dir.list_dir_begin()  # list the directory
		var file_name := dir.get_next()  # get the next file
		while file_name != "":  # while there is a file
			if dir.current_is_dir():  # if the current is a directory
				if file_name == "." or file_name == "..":  # if it is a dot or dot dot
					file_name = dir.get_next()  # get the next file
					continue
				folders.append(file_name)  # add the folder
			file_name = dir.get_next()  # get the next file
	else:
		printerr("An error occurred when trying to access the path " + path)  # print the error
	return folders  # return the folders


func format_seconds(time: float, use_milliseconds: bool = false) -> String:
	var format_string = "%02d:%04.1f" if use_milliseconds else "%02d:%02d"
	return format_string % [time / 60, fmod(time, 60)]


func _on_turn_over() -> void:
	var fen = fen()
	emit_signal("newfen", fen)
	counter += 1
	if counter >= 2:
		counter = 0
		turns_moves.append(turn_moves.join(" "))
		turn_moves.resize(0)


func fen() -> String:
	var pieces = ""
	for rank in range(8):
		var empty = 0
		for file in range(8):
			var spot = Globals.grid.matrix[rank][file]
			if spot == null:
				empty += 1
				if len(pieces) > 0 and str(empty - 1) == pieces[-1]:
					pieces[-1] = str(empty)
				else:
					pieces += str(empty)
			else:
				pieces += (spot.shortname[0].to_upper() if spot.white else spot.shortname[0].to_lower())
				empty = 0
		if rank != 7:
			pieces += "/"
	# handle castling checks
	var whitecastling = PoolStringArray(Globals.white_king.castleing(true)).join(" ")
	var blackcastling = PoolStringArray(Globals.black_king.castleing(true)).join(" ")
	var castlingrights = ""
	if blackcastling and whitecastling:
		castlingrights += "K" if "K" in whitecastling else ""
		castlingrights += "Q" if "Q" in whitecastling else ""
		castlingrights += "k" if "K" in blackcastling else ""
		castlingrights += "q" if "Q" in blackcastling else ""
	else:
		castlingrights = "-"

	var enpassants = ""
	for pawn in Globals.pawns:
		if pawn.twostepfirstmove and pawn.just_set:
			enpassants += to_algebraic(pawn.real_position + (Vector2.DOWN * pawn.whiteint))
	var fen = (
		"%s %s %s %s %s %s"
		% [
			pieces,
			"w" if Globals.team else "b",
			castlingrights,
			enpassants if enpassants else "-",
			Globals.halfmove,
			Globals.fullmove,
		]
	)  # pos  # turn  # castling  # enpassant  # halfmove  # fullmove
	return fen

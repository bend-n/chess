extends Node

var internet := false
signal newmove(move)
signal newfen(fen)

var moves_list: PoolStringArray = []
var fen := ""


func get_pgn():
	return moves_list.join(" ")


func _on_turn_over() -> void:
	fen = get_fen()
	Log.info("fen: " + fen)
	emit_signal("newfen", fen)


func spotispiece(piece_type: int, spot: Piece) -> bool:
	return SanParse.from_str(spot.shortname.to_upper()) == piece_type if spot else false


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
				pieces += (spot.shortname[0].to_upper() if spot.white else spot.shortname[0].to_lower())
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

	var enpassants := ""
	for pawn in Globals.pawns:
		if pawn.just_double_stepped and pawn.just_set:
			enpassants += Utils.to_algebraic(pawn.real_position + (Vector2.DOWN * pawn.whiteint))
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


static func str_bool(string: String) -> bool:
	string = string.to_lower()
	if string == "true":
		return true
	if string == "false":
		return false
	return false


func add_move(move: String) -> void:
	if Globals.turn == false:
		moves_list.append("%s. %s" % [Globals.fullmove, move])
	else:
		moves_list.append(move)
	emit_signal("newmove", move)


func get_args() -> Dictionary:
	var arguments := {}
	for argument in OS.get_cmdline_args():
		var key_value = argument.split("=")
		if len(key_value) == 2:
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			arguments[key_value[0].lstrip("--")] = "true"
	return arguments


func _ready() -> void:
	internet_available()
	Events.connect("turn_over", self, "_on_turn_over")
	if "help" in get_args():
		print("usage: ./chess%s [debug | help]" % exec_ext())
		print("run with command debug to enable debug mode")
		print("run with command help to show this help")
		get_tree().quit()  # dont wait
	Debug.monitor(self, "fen")
	Debug.monitor(self, "pgn", "get_pgn()")


static func exec_ext() -> String:
	if OS.has_feature("Windows"):
		return ".exe"
	elif OS.has_feature("OSX"):
		return ".app/Contents/MacOS/chess"
	elif OS.has_feature("X11"):
		return ".x86_64"
	elif OS.has_feature("web"):
		return ".html"
	return ""


static func is_pawn(inode) -> bool:
	return inode is Pawn


static func is_king(inode) -> bool:
	return inode is King


func reset_vars() -> void:
	moves_list.resize(0)


static func get_node_name(node: Node) -> Array:
	if is_pawn(node):
		return ["♙", "P"] if node.white else ["♟", "P"]
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


func internet_available() -> bool:
	var http := HTTPRequest.new()
	add_child(http)
	var httpurl := "https://1.1.1.1"
	var returnable := http.request(httpurl) == OK
	http.queue_free()
	internet = returnable
	return returnable


func walk_dir(path := "res://assets/pieces", only_dir := true, exclude := []) -> PoolStringArray:  # walk the directory, finding the asset packs
	var files := []  # init the files
	var dir := Directory.new()  # init the directory
	if dir.open(path) == OK:  # open the directory
		dir.list_dir_begin(true)  # list the directory
		var file_name := dir.get_next()  # get the next file
		while file_name != "":  # while there is a file
			if only_dir:
				if dir.current_is_dir():  # if the current is a directory
					files.append(file_name)  # add the folder
			else:
				var split = file_name.split(".")
				if split[-1] == "import" and !split[0] in exclude:
					files.append(split[0])  # add the file
			file_name = dir.get_next()  # get the next file
	else:
		push_error("An error occurred when trying to access the path " + path)  # print the error
	files.sort()  # sort the files
	return PoolStringArray(files)  # return the files


func format_seconds(time: float, use_milliseconds: bool = false) -> String:
	return "%02d:%04.1f" if use_milliseconds else "%02d:%02d" % [time / 60, fmod(time, 60)]


func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		Log.debug("Bye!")


static func to_algebraic(pos: Vector2) -> String:
	var column = "abcdefgh"[pos.x] if pos.x != -1 else ""
	var row = str(round(8 - pos.y)) if pos.y != -1 else ""
	return column + row


static func col_pos(col: String) -> int:
	return "abcdefgh".find(col)


static func row_pos(row: String) -> int:
	return 8 - int(row)


static func from_algebraic(pos: String) -> Vector2:
	return Vector2(col_pos(pos[0]), row_pos(pos[1]))


static func to_str(type: int) -> String:
	return " NBRQK"[type].strip_edges()  # if its a pawn, return nothing


static func append_dict(dict: Dictionary, newdict: Dictionary) -> Dictionary:
	for key in newdict:
		dict[key] = newdict[key]
	return dict

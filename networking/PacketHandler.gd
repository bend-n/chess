extends Node
class_name NetManager

var lobby: Lobby = null
signal hosting(newhosting)
signal game_over
signal game_started

var hosting := false setget set_hosting
var leaving := false


func set_hosting(newhosting: bool) -> void:
	hosting = newhosting
	emit_signal("hosting", newhosting)


func return() -> void:  # return to the void
	if hosting:
		leaving = true
		Globals.network.stopgame("")  # stop hosting
		set_hosting(false)
	lobby.set_buttons(true)
	lobby.set_status("", true)


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	if Utils.internet and get_tree().get_root().has_node("StartMenu"):
		var net := Network.new()
		Events.connect("go_back", self, "_handle_game_over")
		net.connect("move_data", self, "_on_data")
		net.connect("join_result", self, "_on_join_result")
		net.connect("host_result", self, "_on_host_result")
		net.connect("game_over", self, "_handle_game_over")
		net.connect("start_game", self, "_start_game")
		net.connect("connection_established", self, "network_ready")
		add_child(net)
		Globals.network = net
		yield(get_tree().create_timer(.1), "timeout")
		lobby.set_status("Connecting", true)


func requestjoin() -> void:
	lobby.set_buttons(false)
	Globals.network.send_packet(Globals.network.game_code, Globals.network.HEADERS.joinrequest)


func requesthost() -> void:
	lobby.set_buttons(false)
	Globals.network.send_packet(Globals.network.game_code, Globals.network.HEADERS.hostrequest)


func network_ready() -> void:
	lobby.set_status("", true)
	lobby.set_buttons(true)


func _on_join_result(accepted: String) -> void:
	if handle_result(accepted, "Joined!", false):
		Globals.network.relay_signal("startgame", Network.RELAYHEADERS.startgame)


func _on_host_result(accepted: String) -> void:
	set_hosting(handle_result(accepted, "Hosted!"))


func handle_result(accepted: String, resultstring: String, team := true) -> bool:
	Globals.team = team  # what am i doing here???
	if accepted == "Y":
		lobby.set_status(resultstring, true)
		return true
	lobby.set_status(accepted, false)
	lobby.set_buttons(true)
	return false


func _handle_game_over(error := "game over", isok := true) -> void:
	Globals.network.stopgame(error)
	Globals.reset_vars()
	if get_tree().get_root().has_node("Board"):
		get_tree().get_root().get_node("Board").queue_free()
	lobby.set_status(error, isok)
	lobby.toggle(true)
	lobby.set_buttons(true)
	emit_signal("game_over")


func _start_game() -> void:
	set_hosting(false)
	var board: Node2D = load("res://Board.tscn").instance()
	get_tree().get_root().add_child(board)
	lobby.toggle(false)
	emit_signal("game_started")
	lobby.set_buttons(false)


func _on_data(data: String) -> void:
	Globals.add_turn()
	Log.debug([data, " recieved"])
	Utils.add_move(data)
	var mov = SanParse.parse(data)
	match mov.move_kind.type:
		Move.MoveKind.CASTLE:
			var side = 7 if Globals.turn else 0
			var rook: Rook
			var rook_goto: Vector2
			var kingpos = Vector2(4, side)
			var king: King = Piece.at_pos(kingpos)
			var king_goto: Vector2
			match mov.move_kind.data:
				Move.CASTLETYPES.KING_SIDE:
					rook = Piece.at_pos(Vector2(7, side))
					rook_goto = Vector2(5, side)
					king_goto = Vector2(6, side)
				Move.CASTLETYPES.QUEEN_SIDE:
					rook = Piece.at_pos(Vector2(0, side))
					rook_goto = Vector2(3, side)
					king_goto = Vector2(2, side)
				_:
					Log.error("Invalid castle type")
					return
			rook.moveto(rook_goto)
			king.castle(king_goto)
		Move.MoveKind.NORMAL:
			# this needs to handle enpassant, taking, and promotion.
			mov.make_long()
			var positions = mov.move_kind.data
			if mov.promotion != -1:
				var promote_to = SanParse.from_str(mov.promotion)
				Piece.at_pos(positions[0]).promote_to(promote_to, mov.is_capture, positions[1])

			elif mov.is_capture:
				Piece.at_pos(positions[0]).take(Piece.at_pos(positions[1]))

			elif not Piece.at_pos(positions[1]) and mov.piece == SanParser.PAWN:  # if not positions[1] and piece is pawn: enpassant!
				var pawn: Pawn = Piece.at_pos(positions[0])
				pawn.passant(positions[1])
			else:  # a very normal move
				Piece.at_pos(positions[0]).moveto(positions[1])

	# Events.emit_signal("data_recieved")
	# match data["type"]:
	# 	Network.MOVEHEADERS.passant:
	# 		# en passant
	# 		var end_pos := dict2vec(data["positions"][1])
	# 		var start_piece := Piece.at_pos(dict2vec(data["positions"][0]))
	# 		Piece.at_pos(dict2vec(data["positions"][2])).took()  # kill the unfortunate
	# 		start_piece.passant(end_pos)
	# 	Network.MOVEHEADERS.move:
	# 		var start_piece := Piece.at_pos(dict2vec(data["positions"][0]))
	# 		var end_pos := dict2vec(data["positions"][1])
	# 		var end_piece := Piece.at_pos(end_pos)
	# 		if end_piece != null:
	# 			start_piece.take(end_piece)
	# 		else:
	# 			start_piece.moveto(end_pos)

	# 	Network.MOVEHEADERS.promote:
	# 		var dict_data: Dictionary = data["positions"]  # positions is a dict for readability sometimes
	# 	_:
	# 		Log.err("Wtf")

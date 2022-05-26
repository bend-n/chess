extends Node
class_name NetManager

### for the lobby ui
signal set_buttons(enabled)
signal set_status(status, err, isok)
signal set_visible(visibility)
signal hosting(newhosting)

signal game_over
signal game_started

var hosting := false setget set_hosting
var leaving := false

var status := ["", true, false]


func set_buttons(enabled: bool) -> void:
	status[2] = enabled
	emit_signal("set_buttons", enabled)


func set_hosting(newhosting: bool) -> void:
	hosting = newhosting
	emit_signal("hosting", newhosting)


func return() -> void:  # return to the void
	if hosting:
		leaving = true
		Globals.network.send_packet(Globals.network.game_code, Network.HEADERS.stopgame)  # stop hosting
		set_hosting(false)
	set_buttons(true)
	set_status("", true)


func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	if Utils.internet:
		var net := Network.new()
		set_status("Connecting", true)
		Events.connect("go_back", self, "_handle_game_over")
		net.connect("move_data", self, "_on_data")
		net.connect("join_result", self, "_on_join_result")
		net.connect("host_result", self, "_on_host_result")
		net.connect("game_over", self, "_handle_game_over")
		net.connect("start_game", self, "_start_game")
		net.connect("connection_established", self, "network_ready")
		add_child(net)
		Globals.network = net


func requestjoin() -> void:
	set_buttons(false)
	Globals.network.send_packet(Globals.network.game_code, Globals.network.HEADERS.joinrequest)


func requesthost() -> void:
	set_buttons(false)
	Globals.network.send_packet(Globals.network.game_code, Globals.network.HEADERS.hostrequest)


func network_ready() -> void:
	set_status("", true)
	set_buttons(true)


func set_status(text: String, isok: bool) -> void:
	status[0] = text
	status[1] = isok
	emit_signal("set_status", text, isok)


func _on_join_result(accepted: String) -> void:
	if handle_result(accepted, "Joined!", false):
		emit_signal("set_visible", false)
		Globals.network.send_packet(Globals.network.game_code, Globals.network.HEADERS.startgame)


func _on_host_result(accepted: String) -> void:
	set_hosting(handle_result(accepted, "Hosted!"))


func handle_result(accepted: String, resultstring: String, team := true) -> bool:
	Globals.team = team  # what am i doing here???
	if accepted == "Y":
		set_status(resultstring, true)
		return true
	set_status(accepted, false)
	set_buttons(true)
	return false


func _handle_game_over(error := "game over", isok := true) -> void:
	Globals.network.send_packet({"gamecode": Globals.network.game_code, "reason": error}, Network.HEADERS.stopgame)
	Globals.reset_vars()
	if get_tree().get_root().has_node("Board"):
		get_tree().get_root().get_node("Board").queue_free()
	set_status(error, isok)
	emit_signal("set_visible", true)
	set_buttons(true)
	emit_signal("game_over")


func _start_game() -> void:
	set_hosting(false)
	var board: Node2D = load("res://Board.tscn").instance()
	get_tree().get_root().add_child(board)
	emit_signal("set_visible", false)
	emit_signal("game_started")
	set_buttons(false)


func _on_data(data: Dictionary) -> void:
	Globals.add_turn()
	Log.debug([data, " recieved"])
	Events.emit_signal("data_recieved")
	match data["movetype"]:
		Network.MOVEHEADERS.passant:
			# en passant
			var end_pos := dict2vec(data["positions"][1])
			var start_piece := Piece.at_pos(dict2vec(data["positions"][0]))
			Piece.at_pos(dict2vec(data["positions"][2])).took()  # kill the unfortunate
			start_piece.passant(end_pos)
		Network.MOVEHEADERS.move:
			var start_piece := Piece.at_pos(dict2vec(data["positions"][0]))
			var end_pos := dict2vec(data["positions"][1])
			var end_piece := Piece.at_pos(end_pos)
			if end_piece != null:
				start_piece.take(end_piece)
			else:
				start_piece.moveto(end_pos)
		Network.MOVEHEADERS.castle:
			var king := Piece.at_pos(dict2vec(data["positions"]["king"]))
			var rook := Piece.at_pos(dict2vec(data["positions"]["rook"]))
			rook.moveto(dict2vec(data["positions"]["rookdestination"]), true, false, true)
			Utils.add_move(king.castle(dict2vec(data["positions"]["kingdestination"])))
		Network.MOVEHEADERS.promote:
			var dict_data: Dictionary = data["positions"]  # positions is a dict for readability sometimes
			var pawn: Pawn = Piece.at_pos(dict2vec(dict_data["start_position"]))
			var dest := dict2vec(dict_data["destination"])
			if Piece.at_pos(dest) != null:
				Piece.at_pos(dest).took()  # move the pawn to the new place, killing if necessary
				pawn.clear_clicked()
			Globals.grid.make_piece(dest, Pawn.piece(dict_data["become"]), dict_data["white"])  # create the promotion
			pawn.took()  # kill the pawn
			Utils.add_move(dict_data["notation"])  # add a move
			Globals.grid.print_matrix_pretty(Globals.grid.matrix)


static func dict2vec(dict: Dictionary) -> Vector2:
	return Vector2(dict["x"], dict["y"])

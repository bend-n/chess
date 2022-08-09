extends Network

var lobby: Lobby = null
var reconnecting = false
signal hosting(newhosting)
signal signal_recieved(what)
signal chat(text)
signal undo(undo)
signal info_recieved(info)
signal start_game
signal move_data(data)
signal load_pgn(pgn)
signal request_result(what)  # join/host true accepted, false rejected
## for accounts(mostly)
signal signinresult(what)
signal signupresult(what)

const HEADERS := {
	"joinrequest": "J",
	"hostrequest": "H",
	"signup": "C",
	"signin": ">",
	"relay": "R",  # relay goes to both
	"signal": "S",  # signal is one way
	"loadpgn": "L",  # server telling me to load a pgn
	"info": "I",
	"move": "M",
	"undo": "<",
	"spectate": "0"  # its a eye you see
}

var game_code := ""

const RELAYHEADERS := {chat = "C"}
const SIGNALHEADERS := {takeback = "T", draw = "D", resign = "R", info = "I"}  # subheaders for HEADERS.signal

var hosting := false setget set_hosting
var leaving := false
var lock_lobby_status := false


func set_lobby_status(status: String, isok: bool) -> void:
	if !lock_lobby_status:
		lobby.set_status(status, isok)


func set_hosting(newhosting: bool) -> void:
	hosting = newhosting
	emit_signal("hosting", newhosting)


func return() -> void:  # return to the void
	if hosting:
		leaving = true
		set_hosting(false)


func _ready() -> void:
	Events.connect("go_back", self, "go_back")
	if Utils.internet and get_tree().get_root().has_node("StartMenu"):
		yield(get_tree().create_timer(.1), "timeout")
		open_connection()
		set_lobby_status("Connecting", true)
		connect("load_pgn", self, "load_pgn")


func load_pgn(pgn: String) -> void:
	if !Globals.grid:
		_start_game()
	yield(get_tree(), "idle_frame")
	Globals.grid.load_pgn(pgn)  # call deferred wont work since grid obj may be null


func _data_recieved() -> void:
	var data = ws.get_peer(1).get_var()
	Log.net(["RECIEVED:", data])
	var header: String = data.header
	var text = data.data
	match header:
		HEADERS.undo:
			emit_signal("undo", text)
		HEADERS.move:
			if !OS.is_window_focused() and !Debug.debug:  # dont be annoying in debug mode
				OS.request_attention()
			emit_signal("move_data", text.move)
		HEADERS.hostrequest:
			host_result(text)
		HEADERS.relay:
			var relay: Dictionary = text
			match relay.type:
				RELAYHEADERS.chat:
					emit_signal("chat", relay)
		HEADERS.joinrequest:
			join_result(text)
		HEADERS.info:
			yield(get_tree().create_timer(.5), "timeout")
			emit_signal("info_recieved", text)
		HEADERS.spectate:
			# handle spectate here
			if typeof(text) == TYPE_STRING:  # ew error
				set_lobby_status(text, false)
				lobby.set_buttons(true)
				return
			Globals.spectating = true
			_start_game()
			yield(get_tree().create_timer(.5), "timeout")
			Globals.grid.load_pgn(text.pgn)
			emit_signal("info_recieved", text)
		HEADERS.loadpgn:
			emit_signal("load_pgn", text)
		HEADERS.signal:
			var signal: Dictionary = text
			match signal.type:
				_:
					emit_signal("signal_recieved", signal)
		HEADERS.signup:
			emit_signal("signupresult", text)
		HEADERS.signin:
			emit_signal("signinresult", text)
		_:
			Log.err("unknown header %s" % header)


func _connection_established(protocol) -> void:
	._connection_established(protocol)


func _connection_closed(_was_clean_closed) -> void:
	._connection_closed(_was_clean_closed)
	var err = yield(rejoin(), "completed")
	if err:
		go_back("Connection closed, please check your internet, and reload the game.", false)


func _connection_error() -> void:
	._connection_error()
	var err = yield(rejoin(), "completed")
	if err:
		go_back("Connection error, please check your internet, and reload the game.", false)


func join_result(accepted) -> void:
	handle_result(accepted, "Joined!")


func host_result(accepted) -> void:
	set_hosting(handle_result(accepted, "Hosted!"))


func handle_result(accepted, resultstring: String) -> bool:
	emit_signal("request_result", false if typeof(accepted) != TYPE_DICTIONARY else true)
	if typeof(accepted) == TYPE_DICTIONARY:
		Globals.team = "w" if accepted.idx == 0 else "b"
		Log.debug("Team set to " + Utils.expand_color(Globals.team))
		set_lobby_status(resultstring, true)
		return true
	set_lobby_status(accepted, false)
	lobby.set_buttons(true)
	return false


func go_back(error: String, isok: bool) -> void:
	Globals.reset_vars()
	if Globals.playing:
		$"/root/Game".queue_free()
		set_lobby_status(error, isok)
		lobby.toggle(true)
		lobby.focus()
		lobby.set_buttons(true)


func _start_game() -> void:
	set_hosting(false)
	var board: Control = load("res://ui/board/Game.tscn").instance()
	get_tree().get_root().add_child(board)
	lobby.toggle(false)
	emit_signal("start_game")
	lobby.set_buttons(false)
	SoundFx.play("Victory")
	yield(get_tree(), "idle_frame")
	Log.debug("Flipping board" if Globals.team == Chess.BLACK else "Not flipping board")
	if Globals.team == Chess.BLACK:
		board.get_board().flip_board()


func rejoin(tries := 5, interval := 2) -> int:  # on disconnect, try to rejoin
	var err = yield(open_connection(tries, interval), "completed")
	if reconnecting == true:
		return ERR_ALREADY_IN_USE
	reconnecting = true
	Log.info("reconnecting...")
	if not err:
		if Globals.playing:
			Log.info("reconnecting(rejoining)...")
			lock_lobby_status = true
			var rejoined = false
			for try in tries + 1:
				join_game()
				var result = yield(self, "request_result")
				if result:
					disconnect("load_pgn", self, "load_pgn")
					var pgn = yield(self, "load_pgn")
					if Globals.grid.chess.pgn() != pgn:
						Log.info("attempting to load %s" % pgn)
						Globals.grid.load_pgn(pgn)
					connect("load_pgn", self, "load_pgn")
					Log.info("reconnected(rejoined)!")
					rejoined = true
					break
			lock_lobby_status = false
			if rejoined == false:
				Log.err("reconnect failed(rejoin)!")
				reconnecting = false
				return ERR_INVALID_DATA
		else:  # not playing: just reconnect
			Log.info("reconnected!")
	else:
		Log.err("reconnect failed!")
	reconnecting = false
	return err


## packet sending wrapper functions
func signin(data):
	send_packet(data, HEADERS.signin)


func signup(data):
	send_packet(data, HEADERS.signup)


func signal(body: Dictionary, header: String, _mainheader := HEADERS.signal) -> Dictionary:
	var data: Dictionary = Utils.append_dict({"type": header}, body)
	send_gamecode_packet(data, _mainheader)
	return data


func join_game(game: String = game_code) -> void:
	send_gamecode_packet(Creds.get_public(), HEADERS.joinrequest, game)


func host_game(game: String = game_code, white := true, moves_array: PoolStringArray = []) -> void:
	var pckt = Utils.append_dict(Creds.get_public(), {team = white, moves = moves_array})
	send_gamecode_packet(pckt, HEADERS.hostrequest, game)


func spectate(game: String = game_code) -> void:
	send_gamecode_packet(Creds.get_public(), HEADERS.spectate, game)


func send_gamecode_packet(data: Dictionary, header: String, gamecode: String = game_code):
	send_packet(Utils.append_dict({"gamecode": gamecode}, data), header)


func relay_signal(body: Dictionary, header: String) -> Dictionary:  # its really the same thing as signal()
	return signal(body, header, HEADERS.relay)


func send_mov(mov: String) -> void:
	send_gamecode_packet({move = mov}, HEADERS.move)

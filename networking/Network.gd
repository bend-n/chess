extends Node
class_name Network

var ws := WebSocketClient.new()
var game_code := ""

var connected := false

const HEADERS := {
	"joinrequest": "J",
	"hostrequest": "H",
	"stopgame": "K",
	"signup": "C",
	"signin": ">",
	"relay": "R",  # relay goes to both
	"signal": "S",  # signal is one way
	"loadpgn": "L"  # server telling me to load a pgn
}

const MOVEHEADERS := {  # subheaders for HEADERS.move
	"move": "M",
	"take": "K",
	"castle": "C",
	"passant": "P",
	"promote": "Q",
}

const RELAYHEADERS := {"chat": "C"}
const SIGNALHEADERS := {"takeback": "T", "draw": "D", "resign": "R"}  # subheaders for HEADERS.signal

var notation := ""

signal start_game
signal move_data(data)
signal host_result(result)
signal join_result(result)
signal game_over(problem, isok)
signal connection_established
signal signal_recieved(what)

## for accounts(mostly)
signal signinresult(what)
signal signupresult(what)

const url := "wss://gd-chess-server.herokuapp.com/"


func _ready() -> void:
	yield(get_tree(), "idle_frame")  # wait a frame
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_data_recieved")
	ws.connect_to_url(url)


func signin(data):
	send_packet(data, HEADERS.signin)


func signup(data):
	send_packet(data, HEADERS.signup)


func close() -> void:
	ws.disconnect_from_host(0, "Close")


func _connection_established(_protocol) -> void:
	connected = true
	emit_signal("connection_established")
	Log.debug("Connected to server %s..." % url)


func _connection_closed(_was_clean_closed) -> void:
	connected = false
	Log.err("Connection closed")
	emit_signal("game_over", "Connection closed", false)


func _connection_error() -> void:
	connected = false
	Log.err("Connection error")
	emit_signal("game_over", "Connection error", false)


func signal(body, header: String, keyname := "body", _mainheader := HEADERS.signal) -> Dictionary:
	var data := {"type": header, "gamecode": game_code, keyname: body}
	send_packet(data, _mainheader)
	Log.debug("sending signal %s of type %s" % [body, header])
	return data


func join_game(game: String) -> void:
	send_packet({"gamecode": game, "id": SaveLoad.files.id.data.id}, HEADERS.joinrequest)


func host_game(game: String) -> void:
	send_packet({"gamecode": game, "id": SaveLoad.files.id.data.id}, HEADERS.hostrequest)


func relay_signal(body, header: String, keyname := "body") -> Dictionary:  # its really the same thing as signal()
	return signal(body, header, keyname, HEADERS.relay)


func send_mov(mov: Move):
	relay_signal(mov.compile(), MOVEHEADERS.move, "move")


func stopgame(reason: String) -> void:
	var packet := {"reason": reason, "gamecode": game_code}
	send_packet(packet, HEADERS.stopgame)


func _data_recieved() -> void:
	var recieve: Dictionary = ws.get_peer(1).get_var()
	var header: String = recieve.header
	var text = recieve.data
	match header:
		HEADERS.hostrequest:
			emit_signal("host_result", text)
		HEADERS.relay:
			var relay: Dictionary = text
			if relay.type in MOVEHEADERS.values():
				emit_signal("move_data", text.move)
		HEADERS.joinrequest:
			emit_signal("join_result", text)
		HEADERS.loadpgn:
			emit_signal("start_game")
			yield(get_tree().create_timer(.5), "timeout")
			Log.info("load pgn " + text)
			Globals.grid.play_pgn(text, true)  # call deferred wont work since grid obj may be null
		HEADERS.stopgame:
			if !PacketHandler.leaving:  # dont emit the signal if its a stophost thing (HACK)
				emit_signal("game_over", text, true)
			PacketHandler.leaving = false
		HEADERS.signal:
			var signal: Dictionary = text
			emit_signal("signal_recieved", signal)
		HEADERS.signup:
			emit_signal("signupresult", text)
		HEADERS.signin:
			emit_signal("signinresult", text)
		_:
			Log.err("unknown header %s" % header)


func _process(_delta: float) -> void:
	var wsstatus := ws.get_connection_status()
	if wsstatus == ws.CONNECTION_CONNECTING or wsstatus == ws.CONNECTION_CONNECTED:
		ws.poll()


func send_packet(variant, header: String) -> void:
	if ws.get_peer(1).is_connected_to_host():
		ws.get_peer(1).put_var({"header": header, "data": variant})
	else:
		Log.err("not connected to server: packet %s not sent" % variant)

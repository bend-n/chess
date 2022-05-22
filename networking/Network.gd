extends Node
class_name Network

var ws := WebSocketClient.new()
var game_code := ""

var connected = false

const HEADERS := {
	"move": "M",
	"joinrequest": "J",
	"hostrequest": "H",
	"stopgame": "K",
	"ping": "P",
	"startgame": "S",
}

const MOVEHEADERS := {
	"take": "K",
	"move": "M",
	"castle": "C",
	"passant": "P",
	"promote": "Q",
}

var notation := ""

signal start_game
signal move_data(data)
signal host_result(result)
signal join_result(result)
signal game_over(problem, isok)
signal connection_established

const url := "wss://gd-chess-server.herokuapp.com/"


func _ready() -> void:
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_data_recieved")
	Log.debug("Connecting to server %s..." % url)
	ws.connect_to_url(url)
	var t = Timer.new()
	add_child(t)
	t.wait_time = 1
	t.start(1)
	t.connect("timeout", self, "ping")


func ping() -> void:
	send_packet("ping", HEADERS.ping)


func _connection_established(_protocol) -> void:
	connected = true
	emit_signal("connection_established")
	Log.info("Connection established")


func _connection_closed(_was_clean_closed) -> void:
	connected = false
	Log.err("Connection closed")
	emit_signal("game_over", "Connection closed", false)


func _connection_error() -> void:
	connected = false
	Log.err("Connection error")
	emit_signal("game_over", "Connection error", false)


func send_move_packet(positions, header: String) -> void:
	var packet := {"movetype": header, "gamecode": game_code, "positions": positions}
	Globals.add_turn()
	var globals = Globals.pack_vars()
	for variable in globals:
		packet[variable] = globals[variable]
	send_packet(packet, HEADERS.move)  # your move will wait till the server relays back :>


func _data_recieved() -> void:
	var recieve: Dictionary = ws.get_peer(1).get_var()
	var header: String = recieve.header
	var text = recieve.data
	match header:
		HEADERS.hostrequest:
			emit_signal("host_result", text)
		HEADERS.move:
			emit_signal("move_data", text)
		HEADERS.joinrequest:
			emit_signal("join_result", text)
		HEADERS.stopgame:
			emit_signal("game_over", "your opponent requested stop", true)
		HEADERS.startgame:
			emit_signal("start_game")
		HEADERS.ping:
			pass


func _process(_delta) -> void:
	var wsstatus = ws.get_connection_status()
	if wsstatus == ws.CONNECTION_CONNECTING or wsstatus == ws.CONNECTION_CONNECTED:
		ws.poll()


func send_packet(variant, header: String) -> void:
	if ws.get_peer(1).is_connected_to_host():
		ws.get_peer(1).put_var({"header": header, "data": variant})

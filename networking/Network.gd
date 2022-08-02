extends Node
class_name Network

const url := "wss://gd-chess-server.herokuapp.com/"

var ws = WebSocketClient.new()
signal connection_established


func _init():
	SaveLoad.save_string("user://network_log.log", "")  # overwrite last log
	connect_ws_signals()


func connect_ws_signals():
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_data_recieved")


func close() -> void:
	ws.disconnect_from_host(0, "Close")


func _connection_established(_protocol) -> void:
	Log.net("CONNECTED: %s" % url)
	emit_signal("connection_established")  # bubble the signal up


func _connection_closed(_was_clean_closed) -> void:
	Log.net("DISCONNECTED: %s" % url)
	Log.err("Connection closed")


func _connection_error() -> void:
	Log.net("DISCONNECTED: %s" % url)
	Log.err("Connection error")


func _data_recieved():
	pass


func is_open_connection():
	return ws.get_connection_status() == ws.CONNECTION_CONNECTED


func open_connection(tries := 5, interval := 1.0) -> int:
	yield(get_tree(), "idle_frame")
	if is_open_connection():
		return OK
	for try in tries + 1:
		if Utils.request() == OK:
			var err = ws.connect_to_url(url)
			if !err:
				yield(ws, "connection_established")
				if is_open_connection():
					return OK
			else:
				Log.net("CONNECT: failed(%s)" % err)
			if try != tries:
				yield(get_tree().create_timer(interval), "timeout")
	Log.net("CONNECT: failed")
	return ERR_CANT_CONNECT


func _process(_delta: float) -> void:
	var wsstatus: int = ws.get_connection_status()
	if wsstatus == ws.CONNECTION_CONNECTING or wsstatus == ws.CONNECTION_CONNECTED:
		ws.poll()


func send_packet(variant, header: String) -> int:
	var pckt = {header = header, data = variant}
	if is_open_connection():
		ws.get_peer(1).put_var(pckt)
		Log.net("SENT: %s" % pckt)
		return OK
	else:
		Log.err("not connected to server: packet %s not sent" % pckt)
		Log.net("FAILED SEND: %s" % pckt)
		return ERR_CONNECTION_ERROR

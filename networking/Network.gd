extends Node
class_name Network

const url := "wss://gd-chess-server.herokuapp.com/"

var ws := WebSocketClient.new()
var connected := false

signal connection_established


func _ready():
	SaveLoad.save_string("user://network_log.log", "")  # overwrite last log


func open() -> void:
	ws.connect_to_url(url)
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_data_recieved")
	Log.net("OPEN NETWORK: " + url)


func close() -> void:
	ws.disconnect_from_host(0, "Close")


func _connection_established(_protocol) -> void:
	Log.net("CONNECTED TO %s" % url)
	emit_signal("connection_established")  # bubble the signal up
	connected = true


func _connection_closed(_was_clean_closed) -> void:
	connected = false
	Log.net("DISCONNECTED FROM %s" % url)
	Log.err("Connection closed")


func _connection_error() -> void:
	connected = false
	Log.err("Connection error")
	Log.net("DISCONNECTED FROM %s" % url)


func _data_recieved():
	pass


func _process(_delta: float) -> void:
	var wsstatus := ws.get_connection_status()
	if wsstatus == ws.CONNECTION_CONNECTING or wsstatus == ws.CONNECTION_CONNECTED:
		ws.poll()


func send_packet(variant, header: String) -> int:
	var pckt = {header = header, data = variant}
	if ws.get_peer(1).is_connected_to_host():
		ws.get_peer(1).put_var(pckt)
		Log.net("SENT: %s" % pckt)
		return OK
	else:
		Log.err("not connected to server: packet %s not sent" % pckt)
		Log.net("FAILED SEND: %s" % pckt)
		return ERR_CONNECTION_ERROR

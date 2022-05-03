# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
extends Control

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 8910

var peer = null

onready var address: LineEdit = $Back/Center/HBox/VBox/Address
onready var host_button = $Back/Center/HBox/VBox/HBox/HostButton
onready var join_button = $Back/Center/HBox/VBox/HBox/JoinButton
onready var status_ok = $Back/Center/HBox/VBox/StatusOK
onready var status_fail = $Back/Center/HBox/VBox/StatusFail
onready var port_forward_label = $Back/Center/HBox/VBox2/Portforward
onready var find_public_ip_button = $Back/Center/HBox/VBox2/FindPublicIP


func toggle(onoff) -> void:
	visible = onoff


func _ready() -> void:
	address.context_menu_enabled = false
	# Connect all the callbacks related to networking.
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


#### Network callbacks from SceneTree ####


# Callback from SceneTree.
func _player_connected(_id) -> void:
	# Someone connected, start the game!
	var chess = load("res://World.tscn").instance()
	# Connect deferred so we can safely erase it from the callback.
	Utils.connect("game_over", self, "_end_game", [], CONNECT_DEFERRED)

	get_tree().get_root().add_child(chess)


func _player_disconnected(_id) -> void:
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")


# Callback from SceneTree, only for clients (not server).
func _connected_ok() -> void:
	pass  # This function is not needed for this project.


# Callback from SceneTree, only for clients (not server).
func _connected_fail() -> void:
	_set_status("Couldn't connect", false)

	get_tree().set_network_peer(null)  # Remove peer.
	host_button.show()
	address.editable = true


func _server_disconnected() -> void:
	_end_game("Server disconnected")


##### Game creation functions ######


func _end_game(_with_error = "") -> void:
	if has_node("/root/World"):
		# Erase immediately, otherwise network might show
		# errors (this is why we connected deferred above).
		get_node("/root/World").free()
		show()

	get_tree().set_network_peer(null)  # Remove peer.
	host_button.show()
	join_button.show()
	address.editable = true


func _set_status(text, isok) -> void:
	# Simple way to show status.
	if isok:
		status_ok.set_text(text)
		status_fail.set_text("")
		status_ok.visible = len(status_ok.text) > 0
		status_fail.visible = len(status_fail.text) > 0
	else:
		status_ok.set_text("")
		status_fail.set_text(text)
		status_fail.visible = len(status_fail.text) > 0
		status_ok.visible = len(status_ok.text) > 0


func _on_host_pressed() -> void:
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = peer.create_server(DEFAULT_PORT, 1)  # Maximum of 1 peer, since it's a 2-player game.
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.", false)
		return

	get_tree().set_network_peer(peer)
	host_button.hide()
	address.editable = false
	join_button.hide()
	_set_status("Waiting for player...", true)

	# Only show hosting instructions when relevant.


func _on_join_pressed() -> void:
	var ip = address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
		return

	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)


func _on_find_public_ip_pressed() -> void:
	OS.shell_open("https://icanhazip.com/")

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
		lobby.set_status("", true)
		set_hosting(false)
	lobby.set_buttons(true)


func _ready() -> void:
	if Utils.internet and get_tree().get_root().has_node("StartMenu"):
		var net := Network.new()
		Events.connect("go_back", self, "_handle_game_over")
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
	Globals.network.join_game(Globals.network.game_code)


func requesthost() -> void:
	lobby.set_buttons(false)
	Globals.network.host_game(Globals.network.game_code)


func network_ready() -> void:
	lobby.set_status("", true)
	lobby.set_buttons(true)


func _on_join_result(accepted: String) -> void:
	handle_result(accepted, "Joined!", false)


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
	if has_node("/root/Game"):
		get_node("/root/Game").queue_free()
	lobby.set_status(error, isok)
	lobby.toggle(true)
	lobby.set_buttons(true)
	emit_signal("game_over")


func _start_game() -> void:
	set_hosting(false)
	var board: Control = load("res://Game.tscn").instance()
	get_tree().get_root().add_child(board)
	lobby.toggle(false)
	emit_signal("game_started")
	lobby.set_buttons(false)

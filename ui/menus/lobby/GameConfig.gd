extends TabContainer

var moves := PoolStringArray()
var white := true setget set_white
var lobby: Lobby


func _ready():
	find_node("SliderButton").connect("toggled", self, "set_white")


func set_white(new_white: bool) -> void:
	white = new_white


func _on_Continue_pressed():
	PacketHandler.host_game(PacketHandler.game_code, white, moves)
	reset()


func open(_lobby: Lobby):
	show()
	lobby = _lobby


func _on_Stop_pressed():
	reset()


func reset():
	moves = []
	white = true
	$Advanced/H/Pgn.text_changed("")
	hide()


func _on_pgn_selected(_moves: PoolStringArray):
	moves = _moves

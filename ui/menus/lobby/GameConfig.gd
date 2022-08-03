extends TabContainer

var moves := PoolStringArray()
var color := true
var lobby: Lobby

export(ButtonGroup) var button_group: ButtonGroup


func _ready():
	button_group.connect("pressed", self, "_button_pressed")


func _button_pressed(button: BarTextureButton) -> void:
	color = button.name == "White"


func _on_Continue_pressed():
	PacketHandler.host_game(PacketHandler.game_code, color, moves)
	reset()


func open(_lobby: Lobby):
	show()
	lobby = _lobby


func _on_Stop_pressed():
	lobby.set_buttons(true)
	reset()


func reset():
	moves = []
	color = true
	$"%PgnInput".text = ""
	hide()


func _on_pgn_selected(_moves: PoolStringArray):
	moves = _moves

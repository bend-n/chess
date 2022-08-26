extends Control

onready var gameconfig = $"%GameConfig"

var in_game := false


func _ready():
	gameconfig.connect("done", self, "create")


func create(moves: PoolStringArray) -> void:
	var ui: Control = load("res://ui/board/Game.tscn").instance()
	var b: Grid = ui.get_board()
	Log.debug("Set board team to %s" % Utils.expand_color(b.team))
	get_tree().get_root().add_child(ui)
	PacketHandler.lobby.toggle(false)
	yield(get_tree(), "idle_frame")
	b.load_pgn(moves.join(" "))
	Globals.chat.hide()
	in_game = true
	b.team = b.chess.turn
	if b.flipped and b.team == Chess.WHITE:
		b.flip_board()
	get_tree().call_group("userpanel", "hide_children")
	get_tree().call_group("backbutton", "queue_free")


func _pressed():
	if gameconfig.visible:
		create(gameconfig.moves)
	else:
		gameconfig.show()


func _input(_event):
	if Input.is_action_pressed("ui_cancel") and in_game:
		in_game = false
		PacketHandler.go_back("", true)
		get_node("/root/Game").queue_free()
		PacketHandler.lobby.toggle(true)
		Globals.reset_vars()
		get_parent().current_tab = get_parent().get_children().find(self)

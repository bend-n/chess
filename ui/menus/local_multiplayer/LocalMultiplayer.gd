extends Control

onready var gameconfig := $"%GameConfig"

var in_game := false

enum MODES { PVP, PVE, EVE }
enum { HUMAN, ENGINE }

var mode: int = -1

var board_engine_bridge: BoardEngineBridge = null


func create(moves: PoolStringArray, player1_color: bool, players: PoolIntArray, engine_depth: int) -> void:
	assign_mode(players)
	Globals.local = true
	var ui: Control = load("res://ui/board/Game.tscn").instance()
	var b: Grid = ui.get_board()
	b.local = true
	Log.debug("Set board team to %s" % Utils.expand_color(b.team))
	get_tree().get_root().add_child(ui)
	PacketHandler.lobby.toggle(false)

	match mode:
		MODES.PVP:
			pass  # nothing to do ?
		MODES.PVE:
			b.team = "w" if player1_color == true else "b"
			board_engine_bridge = BoardEngineBridge.new(b, [Chess.__swap_color(b.team)], get_tree(), engine_depth)
		MODES.EVE:
			b.team = b.chess.turn
			Globals.spectating = true
			board_engine_bridge = BoardEngineBridge.new(b, ["w", "b"], get_tree(), engine_depth)
	get_tree().call_group("userpanel", "hide")
	get_tree().call_group("backbutton", "queue_free")

	yield(get_tree(), "idle_frame")
	b.load_pgn(moves.join(" "))  # load_pgn emits Events.turn_over
	b.auto_flip()
	Globals.chat.hide()
	in_game = true


func assign_mode(players: PoolIntArray) -> void:
	if players.count(HUMAN) == 2:
		mode = MODES.PVP
	elif players.count(ENGINE) == 2:
		mode = MODES.EVE
	else:
		mode = MODES.PVE


func _pressed():
	if gameconfig.visible:
		create(gameconfig.moves, gameconfig.color, gameconfig.players, gameconfig.depth)
		gameconfig.hide()
	else:
		gameconfig.show()


func _input(_event):
	if Input.is_action_pressed("ui_cancel") and Globals.local == true and in_game:
		Events.emit_signal("go_back", "", true)


func _init() -> void:
	Events.connect("go_back", self, "go_back")


func go_back(_reason: String, _isok: bool) -> void:
	if in_game:
		in_game = false
		if board_engine_bridge:
			board_engine_bridge.kill()
			board_engine_bridge = null
		PacketHandler.go_back("", true)
		get_node("/root/Game").queue_free()
		PacketHandler.lobby.toggle(true)
		Globals.reset_vars()
		get_parent().current_tab = get_parent().get_children().find(self)


class BoardEngineBridge:
	extends Reference

	var b: Grid
	var stockfish: Stockfish
	var playing := PoolStringArray()
	var tree: SceneTree
	var depth: int

	func _init(board: Grid, teams: PoolStringArray, _tree: SceneTree, _depth: int) -> void:
		connect_signals()
		depth = _depth
		tree = _tree
		playing = teams
		b = board
		var loader = StockfishLoader.new()
		stockfish = loader.load_stockfish()
		stockfish.game = b.chess

	func connect_signals():
		Events.connect("turn_over", self, "turn_over")

	func turn_over():
		set_engine_position()
		if stockfish.game.turn in playing:
			play_bestmove()

	func play_bestmove():
		yield(tree, "idle_frame")
		var move: String = yield(bestmove(), "completed")
		b.move(move, false, false)

	func set_engine_position():
		stockfish._position()

	func bestmove() -> String:
		stockfish.go(depth)
		var bestmove = yield(stockfish, "bestmove")
		return bestmove.san

	func kill() -> void:
		stockfish.kill()
		stockfish = null

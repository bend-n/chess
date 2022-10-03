extends Control

onready var gameconfig := $"%GameConfig"

var in_game := false

enum MODES { PVP, PVE, EVE }
enum { HUMAN, ENGINE }

var mode: int = -1

var board_engine_bridge: BoardEngineBridge = null

var ui: GameUI


func create(moves: PoolStringArray, player1_color: bool, players: PoolIntArray, engine_depth: int) -> void:
	assign_mode(players)
	Globals.local = true
	ui = load("res://ui/board/Game.tscn").instance()
	var b: Grid = ui.get_board() as Grid
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
			ui._on_info(BoardEngineBridge.info)
			board_engine_bridge.connect("nps", self, "set_nps", [1 if player1_color == true else 0])
		MODES.EVE:
			b.team = b.chess.turn
			Globals.spectating = true
			board_engine_bridge = BoardEngineBridge.new(b, ["w", "b"], get_tree(), engine_depth)
			ui._spectate_info({white = BoardEngineBridge.info, black = BoardEngineBridge.info})
			board_engine_bridge.connect("nps", self, "set_nps")

	get_tree().call_group("backbutton", "queue_free")

	yield(get_tree(), "idle_frame")
	b.load_pgn(moves.join(" "))  # load_pgn emits Events.turn_over
	b.auto_flip()
	Globals.chat.hide()
	in_game = true


func set_nps(nps: int, on: int = 0 if board_engine_bridge.stockfish.game.turn == "w" else 1) -> void:
	if is_instance_valid(ui.panels[on]):
		ui.panels[on].nps = nps
		ui.panels[1 if on == 0 else 0].nps = 0  # turn it off


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
	signal nps(nps)

	const info := {name = "Stockfish", country = "antartica"}

	var curr_bestmove: Dictionary
	var b: Grid
	var stockfish: Stockfish
	var playing := PoolStringArray()
	var tree: SceneTree
	var depth: int
	var searching: bool = false

	func _init(board: Grid, teams: PoolStringArray, _tree: SceneTree, _depth: int) -> void:
		depth = _depth
		tree = _tree
		playing = teams
		b = board
		var loader = StockfishLoader.new()
		stockfish = loader.load_stockfish()
		stockfish.game = b.chess
		connect_signals()

	func connect_signals():
		stockfish.connect("info", self, "_info")
		Events.connect("turn_over", self, "turn_over")

	func _info(info: Dictionary):
		if searching == false:
			return
		if info.get("nps", false):
			emit_signal("nps", info.nps)
		if info.get("pv", false):
			curr_bestmove = stockfish.game.__move_from_uci(info.pv[0])

	func turn_over():
		set_engine_position()
		if stockfish.game.turn in playing:
			play_bestmove()

	func play_bestmove():
		yield(tree, "idle_frame")
		searching = true
		var move: String = yield(bestmove(), "completed")
		searching = false
		emit_signal("nps", 0)
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

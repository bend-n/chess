extends Control
class_name LocalMultiplayer

onready var gameconfig := $"%GameConfig"

var in_game := false

enum MODES { PVP, PVE, EVE }
enum { HUMAN, ENGINE }

var mode: int = -1

var board_engine_bridge: BoardEngineBridge = null

var ui: GameUI


func create(moves: PoolStringArray, player1_color: bool, players: PoolIntArray, engine_depth: int) -> void:
	assign_mode(players)
	Globals.local = self
	ui = load("res://ui/board/Game.tscn").instance()
	var b: Grid = ui.get_board() as Grid
	b.local = true
	Log.debug("Set board team to %s" % Utils.expand_color(b.team))
	get_tree().get_root().add_child(ui)
	PacketHandler.lobby.toggle(false)
	match mode:
		MODES.PVP:
			b.auto_change_team = true
			b.team = "w"
			ui._on_info({name = "Anonymous", country = "rainbow"})
		MODES.PVE:
			b.team = "w" if player1_color == true else "b"
			board_engine_bridge = BoardEngineBridge.new(b, [Chess.__swap_color(b.team)], get_tree(), engine_depth)
			ui._on_info(BoardEngineBridge.info)
			board_engine_bridge.connect("nps", self, "set_nps", [1 if player1_color == true else 0])
			board_engine_bridge.connect("depth", self, "set_thinking", [1 if player1_color == true else 0])
		MODES.EVE:
			b.team = b.chess.turn
			Globals.spectating = true
			board_engine_bridge = BoardEngineBridge.new(b, ["w", "b"], get_tree(), engine_depth)
			ui._spectate_info({white = BoardEngineBridge.info, black = BoardEngineBridge.info})
			board_engine_bridge.connect("nps", self, "set_nps")
			board_engine_bridge.connect("depth", self, "set_thinking")

	get_tree().call_group("backbutton", "queue_free")

	yield(get_tree(), "idle_frame")
	if mode in [MODES.EVE, MODES.PVE]:
		for panel in ui.panels:
			panel.thinking_display.max_value = engine_depth

	b.load_pgn(moves.join(" "))  # load_pgn emits Events.turn_over
	b.auto_flip()
	Globals.chat.hide()
	in_game = true


func flip_int(i: int) -> int:
	return 1 if i == 0 else 0


func set_nps(nps: int, on: int = 0 if board_engine_bridge.turn == "w" else 1) -> void:
	if is_instance_valid(ui.panels[on]):
		ui.panels[on].nps = nps
		ui.panels[flip_int(on)].nps = 0  # turn it off


#                 thinking: depth
func set_thinking(thinking: int, on: int = 0 if board_engine_bridge.turn == "w" else 1):
	if is_instance_valid(ui.panels[on]):
		if thinking == 0 || ui.panels[on].thinking < thinking:  # depth can go down too
			ui.panels[on].thinking = thinking
		ui.panels[flip_int(on)].thinking = 0


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
	if Input.is_action_pressed("ui_cancel") and Globals.local and in_game:
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


func undo(two: bool = false) -> void:
	board_engine_bridge.undo(two)


class BoardEngineBridge:
	extends Reference
	signal nps(nps)
	signal depth(depth)

	const info := {name = "Stockfish", country = "antartica"}

	var b: Grid
	var stockfish: Stockfish
	var playing := PoolStringArray()
	var tree: SceneTree
	var depth: int
	var searching: bool = false

	var turn: String = "" setget , get_turn

	func get_turn() -> String:
		return stockfish.game.turn

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
		stockfish.connect("bestmove", self, "clear_arrows")
		stockfish.connect("bestmove", self, "play_bestmove")
		Events.connect("turn_over", self, "turn_over")

	func undo(two: bool = false) -> void:
		stockfish.stop()
		b.undo(two)
		set_engine_position()

	func _info(info: Dictionary):
		if searching == false:
			return
		if info.get("nps", false):
			emit_signal("nps", info.nps)
		if info.get("depth", false):
			emit_signal("depth", info.depth)
		if info.get("pv", false):
			var bm = stockfish.game.__move_from_uci(info.pv[0])
			clear_arrows()
			var arrows := b.arrows
			var arrow: Dictionary = arrows.build_arrow(
				Chess.vecfrom0x88(bm.from), Chess.vecfrom0x88(bm.to), Color(0.286275, 0.564706, 0.768627)
			)
			arrow["engine_arrow"] = true
			arrows.arrows.append(arrow)
			arrows.shorten_arrows_at(Chess.vecfrom0x88(bm.to))

	func clear_arrows(_arg = ""):
		var good_array := []
		for arrow in b.arrows.arrows:
			if arrow.get("engine_arrow", false) == false:
				good_array.append(arrow)
		b.arrows.arrows = good_array

	func turn_over():
		set_engine_position()
		if stockfish.game.turn in playing:
			find_bestmove()

	# play_bestmove() will play the move when its found
	func find_bestmove():
		yield(tree, "idle_frame")
		stockfish.go(depth)
		searching = true

	func play_bestmove(move: Dictionary) -> void:
		emit_signal("depth", 0)
		emit_signal("nps", 0)
		b.move(move.san, false, false)

	func set_engine_position():
		stockfish._position()

	func kill() -> void:
		stockfish.kill()
		stockfish = null

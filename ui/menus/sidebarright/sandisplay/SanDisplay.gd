# its really a PGNDisplay but im in no mood to change it
extends PanelContainer

export(PackedScene) var Base

onready var scroll_container := $Scroller
onready var scroll_bar: VScrollBar = scroll_container.get_v_scrollbar()
onready var sans := $Scroller/sanholder

var added_sans := 0


func _ready() -> void:
	scroll_bar.hide()
	scroll_bar.step = .15  #smoth
	Globals.grid.connect("add_to_pgn", self, "add_to_pgn")
	Globals.grid.connect("load_pgn", self, "add_moves")
	Globals.grid.connect("clear_pgn", self, "clear")
	Globals.grid.connect("remove_last", self, "pop")


func create_number_label(num: int) -> void:
	var base = Base.instance()
	sans.add_child(base)
	yield(get_tree(), "idle_frame")
	base.number.text = "%s." % num
	base.name = base.number.text


func add_to_pgn(m: String) -> void:
	add_move(m)
	scroll_down()


func add_move(move: String) -> void:
	if added_sans % 2 == 0:
		# warning-ignore-all:integer_division
		create_number_label((added_sans / 2) + 1)
	added_sans += 1
	sans.get_children()[-1].add_move(move)


func add_moves(moves: PoolStringArray) -> void:
	for move in moves:
		add_move(move)
	scroll_down()


func scroll_down():
	yield(get_tree(), "idle_frame")
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(scroll_bar, "value", scroll_bar.max_value, 0.5)


func clear() -> void:
	added_sans = 0
	for i in sans.get_children():
		i.free()


func pop() -> void:
	added_sans -= 1
	var cs = sans.get_children()
	cs.invert()
	for c in cs:
		if !c.is_queued_for_deletion():
			c.pop_move()
			return


func _gui_input(_e: InputEvent) -> void:
	if Input.is_action_just_pressed("click") and Globals.grid:
		OS.clipboard = Globals.grid.chess.pgn()

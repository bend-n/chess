# its really a PGNDisplay but im in no mood to change it
extends PanelContainer

var tween := Tween.new()

export(PackedScene) var Base

onready var scroll_container := $Scroller
onready var scroll_bar: VScrollBar = scroll_container.get_v_scrollbar()
onready var sans := $Scroller/sanholder

var added_sans := 0


func _ready() -> void:
	scroll_bar.hide()
	scroll_bar.step = .15  #smoth
	add_child(tween)
	if Globals.grid:
		Globals.grid.connect("add_to_pgn", self, "add_move")
		Globals.grid.connect("clear_pgn", self, "clear")
		Globals.grid.connect("remove_last", self, "pop")
	else:
		for i in "hello how do you do":
			add_move(i)


func create_number_label(num: int) -> void:
	var base = Base.instance()
	sans.add_child(base)
	yield(get_tree(), "idle_frame")
	base.number.text = "%s." % num
	base.name = base.number.text


func add_move(move: String) -> void:
	if added_sans % 2 == 0:
		# warning-ignore:integer_division
		create_number_label((added_sans / 2) + 1)
	added_sans += 1
	sans.get_children()[-1].add_move(move)
	scroll_down()


func scroll_down():
	tween.interpolate_property(scroll_bar, "value", scroll_bar.value, scroll_bar.max_value, 0.5, 9)  # bouncy
	tween.start()


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

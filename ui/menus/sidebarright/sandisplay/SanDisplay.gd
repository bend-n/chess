extends PanelContainer

var tween := Tween.new()

export(PackedScene) var Base

onready var scroll_container := $Scroller
onready var scroll_bar: VScrollBar = scroll_container.get_v_scrollbar()
onready var sans := $Scroller/sanholder


func _ready() -> void:
	scroll_bar.step = .15  #smoth
	add_child(tween)
	Utils.connect("newmove", self, "on_new_move")
	Utils.connect("pop_move", self, "reset_moves")


func create_number_label(num: int) -> void:
	var base = Base.instance()
	sans.add_child(base)
	yield(get_tree(), "idle_frame")
	base.number.text = "%s." % num
	base.name = base.number.text


func add_move_to_label(move: String) -> void:
	if !Globals.turn:
		create_number_label(Globals.fullmove)
	sans.get_children()[-1].add_move(move)


func on_new_move(move: String) -> void:
	add_move_to_label(move)
	tween.interpolate_property(scroll_bar, "value", scroll_bar.value, scroll_bar.max_value, 0.5, 9)  # bouncy
	tween.start()


func reset_moves() -> void:
	for i in sans.get_children():
		i.queue_free()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		OS.clipboard = Utils.get_pgn()

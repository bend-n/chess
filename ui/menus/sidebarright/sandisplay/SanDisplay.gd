extends ScrollContainer

var tween := Tween.new()

export(PackedScene) var Base

onready var scroll_container := self
onready var scroll_bar := get_v_scrollbar()
onready var sans := $V


func _ready() -> void:
	scroll_bar.step = .15
	add_child(tween)
	Utils.connect("newmove", self, "on_new_move")


func create_number_label(num: int) -> void:
	var base = Base.instance()
	sans.add_child(base)
	yield(get_tree(), "idle_frame")
	base.number.text = "%s." % str(num)


func add_move_to_label(move: String) -> void:
	sans.get_children()[-1].add_move(move)


func on_new_move(move: String) -> void:
	if !Globals.turn:  # black just moved
		yield(create_number_label(Globals.fullmove), "completed")
	add_move_to_label(move)
	tween.interpolate_property(  # scrolldown
		scroll_bar, "value", scroll_bar.value, scroll_bar.max_value, 0.5, Tween.TRANS_BOUNCE
	)
	tween.start()

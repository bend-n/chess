extends ScrollContainer

var tween := Tween.new()

onready var scroll_container := self
onready var scroll_bar := get_v_scrollbar()
onready var sans := $sans


func _ready() -> void:
	add_child(tween)
	Utils.connect("newmove", self, "on_new_move")


func create_number_label(num: int) -> void:
	var clr := ColorRect.new()
	clr.color = Color(1, 1, 1, 0.13)
	clr.rect_min_size = Vector2(100, 30)
	var label := Label.new()
	label.text = " %s." % str(num)
	label.align = Label.ALIGN_LEFT
	label.valign = Label.VALIGN_CENTER
	clr.add_child(label)
	sans.add_child(clr)


func create_san_label(text: String, alignment := Label.ALIGN_RIGHT) -> void:
	var label := Label.new()
	label.text = text
	label.valign = Label.VALIGN_CENTER
	label.align = alignment
	label.rect_min_size = Vector2(rect_size.x / 3, 0)
	sans.add_child(label)


func on_new_move(move: String) -> void:
	var alignment := Label.ALIGN_RIGHT
	if !Globals.turn:  # black just moved
		alignment = Label.ALIGN_LEFT
		create_number_label(Globals.fullmove)
	create_san_label(move, alignment)
	tween.interpolate_property(  # scrolldown
		scroll_bar, "value", scroll_bar.value, scroll_bar.max_value, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
	)
	tween.start()

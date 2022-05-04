extends ScrollContainer

var tween: Tween

var number = 1

onready var scroll_container = self
onready var scroll_bar = get_v_scrollbar()
onready var sans = $sans


func _ready() -> void:
	tween = Tween.new()
	add_child(tween)
	Utils.connect("newmove", self, "on_new_move")


func create_number_label(num) -> void:
	var clr = ColorRect.new()
	clr.color = Color(1, 1, 1, 0.13)
	clr.rect_min_size = Vector2(70, 30)
	var label = Label.new()
	label.text = str(num) + ".  "
	label.align = Label.ALIGN_RIGHT
	label.valign = Label.VALIGN_CENTER
	label.rect_min_size = clr.rect_min_size
	clr.add_child(label)
	sans.add_child(clr)


func create_san_label(text, alignment = Label.ALIGN_RIGHT) -> void:
	var label = Label.new()
	label.text = text
	label.valign = Label.VALIGN_CENTER
	label.align = alignment
	label.rect_min_size = Vector2(115, 0)
	sans.add_child(label)


func on_new_move(move) -> void:
	var alignment = Label.ALIGN_RIGHT
	if !Globals.turn:  # black just moved
		alignment = Label.ALIGN_LEFT
		create_number_label(Globals.fullmove)
		number = 0
	create_san_label(move, alignment)
	tween.interpolate_property(  # scrolldown
		scroll_bar, "value", scroll_bar.value, scroll_bar.max_value, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
	)
	tween.start()

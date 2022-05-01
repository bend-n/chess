extends ItemList

onready var scrollbar = get_v_scroll()
var tween: Tween


func _ready():
	tween = Tween.new()
	add_child(tween)
	Utils.connect("newmove", self, "on_new_move")


func on_new_move(move):
	add_item(move)
	tween.interpolate_property(  # scrolldown
		scrollbar, "value", scrollbar.value, scrollbar.max_value, 0.5, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT
	)
	tween.start()
	scrollbar.value = scrollbar.max_value

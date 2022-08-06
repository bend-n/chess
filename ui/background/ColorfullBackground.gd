extends ColorRect

export(PoolColorArray) var colors
export(float) var length := 2.8

var rainbow := true
onready var fallback_color = color


static func rand(clr) -> float:
	return clamp(clr + rand_range(0, .1) if randi() % 2 else clr - rand_range(0, .1), 0, 1)


func _ready() -> void:
	randomize()
	color = colors[randi() % colors.size()]
	change_color()


func create_timer():
	get_tree().create_timer(length).connect("timeout", self, "change_color")


func change_color() -> void:
	create_timer()
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	if rainbow:
		var chosen: Color = colors[randi() % colors.size()]
		var clr = Color(rand(chosen.r), rand(chosen.g), rand(chosen.b), 1)
		tween.tween_property(self, "color", clr, length)
	else:
		tween.tween_property(self, "color", fallback_color, length)

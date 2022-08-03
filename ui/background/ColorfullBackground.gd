extends ColorRect

export(PoolColorArray) var colors
export(float) var length := 2.8

onready var fallback_color = color

var rainbow := true setget set_rainbow
var tween := Tween.new()
var timer := Timer.new()


static func rand(clr) -> float:
	return clamp(clr + rand_range(0, .1) if randi() % 2 else clr - rand_range(0, .1), 0, 1)


func set_rainbow(newrainbow):
	rainbow = newrainbow
	change_color()


func _ready() -> void:
	randomize()
	add_child(tween)
	add_child(timer)
	timer.connect("timeout", self, "change_color")
	color = colors[randi() % colors.size()]
	change_color()


func change_color() -> void:
	timer.start(length)
	if rainbow:
		var clr: Color = colors[randi() % colors.size()]
		clr = Color(rand(clr.r), rand(clr.g), rand(clr.b), 1)
		tween.interpolate_property(self, "color", color, clr, length, Tween.TRANS_ELASTIC)
	else:
		tween.interpolate_property(self, "color", color, fallback_color, length, Tween.TRANS_ELASTIC)
	tween.start()

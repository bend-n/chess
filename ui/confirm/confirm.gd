extends WindowDialog
class_name Confirm

signal confirmed(what)

var timer := Timer.new()


func _process(_delta):
	if visible:
		rect_position.x = clamp(rect_position.x, 0, OS.get_window_size().x - rect_size.x)
		rect_position.y = clamp(rect_position.y, 50, OS.get_window_size().y - rect_size.y)


func _ready() -> void:
	add_child(timer)
	timer.connect("timeout", self, "_pressed", [false])


func confirm(who, what: String, timeout := 5, called := "_confirmed"):
	connect("confirmed", who, called)
	popup_centered()
	window_title = what
	timer.start(timeout)


func _pressed(what: bool):
	emit_signal("confirmed", what)
	queue_free()

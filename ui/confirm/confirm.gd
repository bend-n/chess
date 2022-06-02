extends WindowDialog
class_name Confirm

signal confirmed(what)

var timer := Timer.new()


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

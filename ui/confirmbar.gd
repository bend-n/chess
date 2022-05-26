extends Control
class_name Confirm

signal confirmed(what)

export(NodePath) onready var status = get_node(status) as StatusLabel

var timer := Timer.new()
var looking: Node = null


func _ready() -> void:
	add_child(timer)
	timer.connect("timeout", self, "_pressed", [false])


func _timeout() -> void:
	_pressed(false)


func stop_looking() -> void:
	looking = null
	timer.stop()
	hide()


func confirm(who: Node, what: String, timeout := 5):
	if is_instance_valid(looking):
		looking.stoplooking()
	looking = who
	show()
	status.set_text(what, timeout)
	timer.start(timeout)


func _pressed(what: bool):
	status.set_text("", 0)
	emit_signal("confirmed", what)
	stop_looking()

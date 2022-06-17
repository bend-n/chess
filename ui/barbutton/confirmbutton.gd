extends BarTextureButton
class_name ConfirmButton

const Confirm = preload("res://ui/confirm/Confirm.tscn")
var waiting_on_answer: Confirm = null
export(String) var confirm_text = ""


func _ready() -> void:
	PacketHandler.connect("game_over", self, "set_disabled", [true])
	if Globals.network:
		Globals.network.connect("signal_recieved", self, "_signal_recieved")


func confirm() -> void:
	var confirm = Confirm.instance()
	add_child(confirm)
	confirm.confirm(self, confirm_text, 20)
	waiting_on_answer = confirm


func _signal_recieved(_signal: Dictionary) -> void:
	pass


func _confirmed(what: bool) -> void:
	if waiting_on_answer:
		if !waiting_on_answer.is_queued_for_deletion():
			waiting_on_answer.queue_free()
		waiting_on_answer = null
		if what:
			after_confirmed()


func after_confirmed() -> void:
	pass

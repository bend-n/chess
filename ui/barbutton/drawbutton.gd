extends BarTextureButton
class_name DrawButton, "res://assets/ui/draw.png"

export(NodePath) onready var status = get_node(status) as StatusLabel
export(NodePath) onready var confirmbar = get_node(confirmbar) as Confirm

var waiting_on_answer := false


func _ready() -> void:
	Globals.network.connect("request", self, "draw_request")
	Globals.network.connect("request_result", self, "_on_draw_result")


func draw_request(what: Dictionary):
	if what.type == Network.REQUESTHEADERS.draw:
		if "questions" in what:
			Log.err("Draw request without prompt")
			return
		confirmbar.confirm(self, what.question, 20)
		waiting_on_answer = true


func drawed() -> GDScriptFunctionState:
	return Globals.grid.drawed("mutual agreement")


func stoplooking() -> void:
	_handle_confirm(false)


func _pressed() -> void:
	if waiting_on_answer:
		_handle_confirm(true)
		confirmbar.stop_looking()
	else:
		disabled = true
		Globals.network.send_request_packet(
			Network.REQUESTHEADERS.draw, "Your opponent wishes to draw, do you accept?"
		)
		status.set_text("Draw request sent")


func _on_draw_result(accepted: Dictionary) -> void:  # called from _handle_confirm
	disabled = false
	if accepted.type == Network.REQUESTHEADERS.draw:
		if accepted.answer:
			drawed()
		else:
			status.set_text("Your opponent has rejected the draw request.")


func _handle_confirm(yes: bool) -> void:  # called from confirmbar.confirmed
	if waiting_on_answer:
		disabled = false
		waiting_on_answer = false
		Globals.network.send_request_answer_packet(Network.REQUESTHEADERS.draw, yes)
		if yes:
			drawed()

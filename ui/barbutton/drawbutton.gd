extends BarTextureButton
class_name DrawButton, "res://assets/ui/draw.png"

export(NodePath) onready var status = get_node(status) as StatusLabel
export(NodePath) onready var confirmbar = get_node(confirmbar) as Confirm

var waiting_on_answer := false


func _ready():
	if Globals.network:
		Globals.network.connect("signal_recieved", self, "_on_signal")


func _on_signal(what: Dictionary):
	if what.type == Network.SIGNALHEADERS.draw:
		if "question" in what:
			confirmbar.confirm(self, "Your opponent requests a draw", 20)
			waiting_on_answer = true
		else:
			disabled = false
			if what.accepted:
				drawed()
			else:
				status.set_text("Your opponent rejected the draw")


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
		Globals.network.signal("", Network.SIGNALHEADERS.draw, "question")
		status.set_text("Draw request sent")


func _handle_confirm(yes: bool) -> void:  # called from confirmbar.confirmed
	if waiting_on_answer:
		disabled = false
		waiting_on_answer = false
		Globals.network.signal(yes, Network.SIGNALHEADERS.draw, "accepted")
		if yes:
			drawed()

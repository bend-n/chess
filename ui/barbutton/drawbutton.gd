extends ConfirmButton
class_name DrawButton, "res://assets/ui/draw.png"


func _signal_recieved(what: Dictionary) -> void:
	if what.type == Network.SIGNALHEADERS.draw:
		if "question" in what:
			confirm()
		else:
			if what.accepted:
				drawed()
			else:
				status.set_text("Draw request rejected")


func drawed() -> GDScriptFunctionState:
	return Globals.grid.drawed("mutual agreement")


func _pressed() -> void:
	if waiting_on_answer:
		_confirmed(true)
	else:
		Globals.network.signal({"question": ""}, Network.SIGNALHEADERS.draw)
		status.set_text("Draw request sent")


func _confirmed(what: bool) -> void:  # called from confirmbar.confirmed
	._confirmed(what)
	Globals.network.signal({"accepted": what}, Network.SIGNALHEADERS.draw)
	if what:
		drawed()

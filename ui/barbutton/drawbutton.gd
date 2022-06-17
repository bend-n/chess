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
				Globals.chat.server("Draw request rejected")


func drawed() -> GDScriptFunctionState:
	return Globals.grid.drawed("mutual agreement")


func _pressed() -> void:
	if Globals.spectating:
		return
	if waiting_on_answer:
		_confirmed(true)
	else:
		Globals.network.signal({"question": ""}, Network.SIGNALHEADERS.draw)
		Globals.chat.server("Draw request sent")


func _confirmed(what: bool) -> void:  # called from confirmbar.confirmed
	._confirmed(what)
	Globals.network.signal({"accepted": what}, Network.SIGNALHEADERS.draw)
	if what:
		drawed()

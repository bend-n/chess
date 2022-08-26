extends ConfirmButton
class_name ResignButton


func _signal_recieved(what: Dictionary) -> void:
	if what.type == PacketHandler.SIGNALHEADERS.resign:
		Globals.grid.win(Globals.grid.team, "resignation")


func _pressed() -> void:
	if Globals.spectating:
		return
	if waiting_on_answer:
		_confirmed(true)
	else:
		confirm()


func after_confirmed():
	PacketHandler.signal({}, PacketHandler.SIGNALHEADERS.resign)
	Globals.grid.win("w" if Globals.grid.team == "b" else "b", "resignation")
	disabled = true

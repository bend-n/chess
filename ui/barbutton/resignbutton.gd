extends ConfirmButton
class_name ResignButton, "res://assets/ui/flag.png"


func _signal_recieved(what: Dictionary) -> void:
	if what.type == Network.SIGNALHEADERS.resign:
		Globals.grid.win(Globals.team, "resignation")


func _pressed() -> void:
	if Globals.spectating:
		return
	if waiting_on_answer:
		_confirmed(true)
	else:
		confirm()


func after_confirmed():
	Globals.network.signal({}, Network.SIGNALHEADERS.resign)
	Globals.grid.win(!Globals.team, "resignation")
	disabled = true

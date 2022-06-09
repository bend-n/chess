extends ConfirmButton
class_name UndoButton, "res://assets/ui/undo.png"


func _ready():
	Globals.network.connect("undo", self, "undo_recieved")


func _pressed():
	if waiting_on_answer:
		_confirmed(true)
	else:
		if Utils.moves_list.size() == 0:
			status.set_text("No moves to undo!")
			return
		elif Globals.turn == Globals.team:
			status.set_text("It is your turn!")
			return
		Globals.network.send_packet(
			{gamecode = Globals.network.game_code, question = ""}, Network.HEADERS.undo
		)
		status.set_text("Undo request sent")


func undo_recieved(sig: Dictionary) -> void:
	if "question" in sig:
		confirm()
	else:
		if sig.accepted:
			status.set_text("Undo request accepted")
			undo()
		else:
			status.set_text("Undo request rejected")


func _confirmed(what: bool) -> void:
	._confirmed(what)
	Globals.network.send_packet(
		{gamecode = Globals.network.game_code, accepted = what}, Network.HEADERS.undo
	)
	if what:
		undo()


func undo():
	Globals.grid.undo()

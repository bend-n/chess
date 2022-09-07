extends ConfirmButton
class_name UndoButton

onready var status := get_node("%Status") as StatusLabel
const undo_request_message = "%s requested a undo"
const undo_declined_message = "undo declined"


func _ready() -> void:
	PacketHandler.connect("undo", self, "undo_signal_recieved")


func _pressed() -> void:
	if Globals.spectating:
		return
	if waiting_on_answer:
		_confirmed(true)
	else:
		var two_undos = true if Globals.grid.chess.turn == Globals.grid.team else false
		var completed_moves = Globals.grid.chess.history().size()
		if completed_moves == 0 or (two_undos && completed_moves == 1):
			status.set_text("No moves to undo!")
			return
		var msg = undo_request_message % Utils.expand_color(Globals.grid.team)
		var pckt = {gamecode = PacketHandler.game_code, question = msg, two = two_undos}
		status.clear_text()
		PacketHandler.send_packet(pckt, PacketHandler.HEADERS.undo)
		Globals.chat.server(msg)
		set_disabled(true)


func undo_signal_recieved(sig: Dictionary) -> void:
	if "question" in sig:
		Globals.chat.server(sig.question)
		confirm()
	else:
		set_disabled(false)
		if sig.accepted:
			undo(sig.two)
		else:
			# declined signal reception
			Globals.chat.server(undo_declined_message)


func _confirmed(what: bool) -> void:
	._confirmed(what)
	var two_undos = not Globals.grid.is_my_turn()  # not my turn
	var pckt = {gamecode = PacketHandler.game_code, accepted = what, two = two_undos}
	PacketHandler.send_packet(pckt, PacketHandler.HEADERS.undo)
	if what:
		undo(two_undos)
	else:
		# pressed no reception
		Globals.chat.server(undo_declined_message)


func undo(two_undos := false):
	Globals.grid.undo(two_undos)
	status.clear_text()

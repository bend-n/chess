extends ConfirmButton
class_name UndoButton, "res://assets/ui/undo.png"

export(NodePath) onready var status = get_node(status) as StatusLabel
const undo_request_message = "%s requested a undo"
const undo_declined_message = "undo declined"


func _ready() -> void:
	if PacketHandler:
		PacketHandler.connect("undo", self, "undo_signal_recieved")


func _pressed() -> void:
	if Globals.spectating:
		return
	if waiting_on_answer:
		_confirmed(true)
	else:
		if Utils.moves_list.size() == 0:
			status.set_text("No moves to undo!")
			return
		elif Globals.turn == Globals.team:
			status.set_text("It is your turn!")
			return
		PacketHandler.send_packet({gamecode = PacketHandler.game_code, question = ""}, PacketHandler.HEADERS.undo)
		Globals.chat.server(undo_request_message % Globals.get_team())
		set_disabled(true)


func undo_signal_recieved(sig: Dictionary) -> void:
	if "question" in sig:
		Globals.chat.server(undo_request_message % Globals.str_bool(!Globals.team))
		confirm()
	else:
		set_disabled(false)
		if sig.accepted:
			undo()
		else:
			# declined signal reception
			Globals.chat.server(undo_declined_message)


func _confirmed(what: bool) -> void:
	._confirmed(what)
	PacketHandler.send_packet({gamecode = PacketHandler.game_code, accepted = what}, PacketHandler.HEADERS.undo)
	if what:
		undo()
	else:
		# pressed no reception
		Globals.chat.server(undo_declined_message)


func undo():
	var numberex = SanParse.compile("([0-9]+)\\.", false)
	var which_move = 0
	var mov = Utils.moves_list[-1]
	var result = numberex.search(mov)
	if result:
		which_move = result.strings[1]
	else:
		result = numberex.search(Utils.moves_list[-2])
		which_move = result.strings[1] if result else 0
	var pgn = Utils.pop_move()
	Globals.chat.server("Move (%s) %s undone" % [which_move, mov.split(" ")[-1]])
	Globals.grid.undo(pgn)
	status.set_text("")

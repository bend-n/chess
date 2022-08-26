extends ConfirmButton
class_name DrawButton

const draw_declined_message = "draw request rejected"
const draw_request_message = "%s requests a draw"


func _signal_recieved(what: Dictionary) -> void:
	if what.type == PacketHandler.SIGNALHEADERS.draw:
		set_disabled(false)
		if "question" in what:
			confirm()
			Globals.chat.server(what.question)
		else:
			if what.accepted:
				draw()
			else:
				# declined signal recieved
				Globals.chat.server(draw_declined_message)


func draw():
	Globals.grid.draw("mutual agreement")


func _pressed() -> void:
	if Globals.spectating:
		return
	if waiting_on_answer:
		_confirmed(true)
	else:
		set_disabled(true)
		var msg = draw_request_message % Utils.expand_color(Globals.grid.team)
		PacketHandler.signal({question = msg}, PacketHandler.SIGNALHEADERS.draw)
		Globals.chat.server(msg)


func _confirmed(what: bool) -> void:  # called from confirmbar.confirmed
	._confirmed(what)
	PacketHandler.signal({"accepted": what}, PacketHandler.SIGNALHEADERS.draw)
	if what:
		draw()
	else:
		# no pressed
		Globals.chat.server(draw_declined_message)

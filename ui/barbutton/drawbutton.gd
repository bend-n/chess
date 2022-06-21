extends ConfirmButton
class_name DrawButton, "res://assets/ui/draw.png"

const draw_declined_message = "draw request rejected"
const draw_request_message = "%s requests a draw"


func _signal_recieved(what: Dictionary) -> void:
	if what.type == PacketHandler.SIGNALHEADERS.draw:
		set_disabled(false)
		if "question" in what:
			confirm()
			Globals.chat.server(draw_request_message % Globals.str_bool(!Globals.team))
		else:
			if what.accepted:
				drawed()
			else:
				# declined signal recieved
				Globals.chat.server(draw_declined_message)


func drawed() -> GDScriptFunctionState:
	return Globals.grid.drawed("mutual agreement")


func _pressed() -> void:
	if Globals.spectating:
		return
	if waiting_on_answer:
		_confirmed(true)
	else:
		set_disabled(true)
		PacketHandler.signal({"question": ""}, PacketHandler.SIGNALHEADERS.draw)
		Globals.chat.server(draw_request_message % Globals.get_team())


func _confirmed(what: bool) -> void:  # called from confirmbar.confirmed
	._confirmed(what)
	PacketHandler.signal({"accepted": what}, PacketHandler.SIGNALHEADERS.draw)
	if what:
		drawed()
	else:
		# no pressed
		Globals.chat.server(draw_declined_message)

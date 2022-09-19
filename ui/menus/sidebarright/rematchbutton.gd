extends ConfirmButton
class_name RematchButton

const request_message = "%s requested a rematch"
const declined_message = "rematch declined"

onready var status := get_node("%Status") as StatusLabel


func _ready() -> void:
	PacketHandler.connect("rematch_result", self, "signal_recieved")


func _pressed() -> void:
	if Globals.spectating:
		return
	if waiting_on_answer:
		_confirmed(true)
	else:
		var msg = request_message % Utils.expand_color(Globals.grid.team)
		var pckt = {gamecode = PacketHandler.game_code, question = msg}
		PacketHandler.send_packet(pckt, PacketHandler.HEADERS.rematch)
		Globals.chat.server(msg)
		set_disabled(true)


func signal_recieved(sig: Dictionary) -> void:
	if "question" in sig:
		Globals.chat.server(sig.question)
		confirm()
	else:
		set_disabled(false)
		if sig.accepted:
			rematch()
		else:
			# declined signal reception
			Globals.chat.server(declined_message)


func _confirmed(what: bool) -> void:
	._confirmed(what)
	var pckt = {gamecode = PacketHandler.game_code, accepted = what}
	PacketHandler.send_packet(pckt, PacketHandler.HEADERS.rematch)
	if what:
		rematch()
	else:
		# pressed no reception
		Globals.chat.server(declined_message)


func rematch():
	Globals.chat.server("reloaded")
	status.clear_text()
	Globals.grid.reload()
	get_tree().call_group("showongameover", "hide")  # they go back to hidden now.
	get_tree().call_group("hideongameover", "show")  # and vice versa
	get_tree().call_group("hideongameoverifnolocalmultiplayer", "show")

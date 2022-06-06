extends BarTextureButton
class_name DrawButton, "res://assets/ui/draw.png"

const Confirm = preload("res://ui/confirm/Confirm.tscn")
var waiting_on_answer: Confirm = null

export(NodePath) onready var status = get_node(status) as StatusLabel


func _ready() -> void:
	PacketHandler.connect("game_over", self, "set_disabled", [true])
	if Globals.network:
		Globals.network.connect("signal_recieved", self, "_on_signal")


func _on_signal(what: Dictionary) -> void:
	if what.type == Network.SIGNALHEADERS.draw:
		if "question" in what:
			var confirm = Confirm.instance()
			add_child(confirm)
			confirm.confirm(self, "Your opponent wants to draw", 20)
			waiting_on_answer = confirm
		else:
			disabled = false
			if what.accepted:
				drawed()
			else:
				status.set_text("Your opponent rejected the draw")


func drawed() -> GDScriptFunctionState:
	return Globals.grid.drawed("mutual agreement")


func _pressed() -> void:
	if waiting_on_answer:
		_confirmed(true)
	else:
		disabled = true
		Globals.network.signal({"question": ""}, Network.SIGNALHEADERS.draw)
		status.set_text("Draw request sent")


func _confirmed(yes: bool) -> void:  # called from confirmbar.confirmed
	if waiting_on_answer:
		if !waiting_on_answer.is_queued_for_deletion():
			waiting_on_answer.queue_free()
		disabled = false
		waiting_on_answer = null
		Globals.network.signal({"accepted": yes}, Network.SIGNALHEADERS.draw)
		if yes:
			drawed()

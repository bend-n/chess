extends BarTextureButton
class_name ResignButton, "res://assets/ui/flag.png"

const Confirm = preload("res://ui/confirm/Confirm.tscn")
var waiting_on_answer: Confirm = null

export(NodePath) onready var status = get_node(status) as StatusLabel


func _ready() -> void:
	PacketHandler.connect("game_over", self, "set_disabled", [true])
	if Globals.network:
		Globals.network.connect("signal_recieved", self, "resigned")


func resigned(what: Dictionary) -> void:
	if what.type == Network.SIGNALHEADERS.resign:
		Globals.grid.win(Globals.team, "resignation")


func _pressed() -> void:
	if waiting_on_answer:
		_confirmed(true)
	else:
		var confirm = Confirm.instance()
		add_child(confirm)
		confirm.confirm(self, "Resign?", 20)
		waiting_on_answer = confirm


func _confirmed(what: bool) -> void:
	if waiting_on_answer:
		if !waiting_on_answer.is_queued_for_deletion():
			waiting_on_answer.queue_free()
		waiting_on_answer = null
		if what:
			Globals.network.signal({}, Network.SIGNALHEADERS.resign)
			Globals.grid.win(!Globals.team, "resignation")
			disabled = true

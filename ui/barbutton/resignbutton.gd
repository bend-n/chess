extends BarTextureButton
class_name ResignButton, "res://assets/ui/flag.png"

export(NodePath) onready var status = get_node(status) as StatusLabel
export(NodePath) onready var drawbutton = get_node(drawbutton) as DrawButton
export(NodePath) onready var confirmbar = get_node(confirmbar) as Confirm

var waiting_on_answer = false


func _ready() -> void:
	Globals.network.connect("request", self, "resigned")


func resigned(what: Dictionary):
	if what.type == Network.REQUESTHEADERS.resign:
		Globals.grid.win(Globals.team, "resignation")


func _pressed() -> void:
	if waiting_on_answer:
		_confirmed(true)
		confirmbar.stop_looking()
	else:
		confirmbar.confirm(self, "Resign?", 20)
		waiting_on_answer = true
		drawbutton.disabled = true


func stoplooking() -> void:
	_confirmed(false)


func _confirmed(what: bool):
	if waiting_on_answer:
		waiting_on_answer = false
		drawbutton.disabled = what  # dont un disable it if the game is over
		if what:
			Globals.network.send_request_packet(Network.REQUESTHEADERS.resign, "")
			Globals.grid.win(!Globals.team, "resignation")
			disabled = true

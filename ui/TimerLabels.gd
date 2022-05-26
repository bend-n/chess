extends Label

var time: float setget set_time
var stop := false

const STARTTIME = 300

export(bool) var white := false

onready var colorrect := $ColorRect


func set_time(newtime: float) -> bool:
	if stop:
		return false
	time = newtime
	if time <= 0.0:
		Events.emit_signal("outoftime", white)
		stop = true
		text = "00:00.0"
		return false
	var use_millis := time <= 10
	text = Utils.format_seconds(time, use_millis)
	return true


func _ready() -> void:
	set_time(STARTTIME)
	set_color()
	colorrect.show_behind_parent = true
	Events.connect("data_recieved", self, "set_color")
	Events.connect("game_over", self, "_on_game_over")


func _on_game_over() -> void:
	stop = true


func set_color() -> void:
	if time > 10:
		colorrect.color = Globals.grid.clockrunning_color if Globals.turn == white else Color.transparent
	else:
		colorrect.color = Globals.grid.clockrunninglow if Globals.turn == white else Globals.grid.clocklow

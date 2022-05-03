extends Label

var time := 0.0 setget set_time
var stop := false

export(bool) var white := false

onready var colorrect := $ColorRect


func set_time(newtime) -> bool:
	if stop:
		return false
	time = newtime
	if time <= 0.0:
		Events.emit_signal("outoftime", "white" if white else "black")
		stop = true
		text = "00:00.0"
		return false
	var use_millis := time <= 10
	text = Utils.format_seconds(time, use_millis)
	return true


func _ready() -> void:
	_on_turn_over()
	colorrect.show_behind_parent = true
	colorrect.color = Globals.grid.overlay_color
	Events.connect("turn_over", self, "_on_turn_over")
	Events.connect("game_over", self, "_on_game_over")


func _on_game_over() -> void:
	stop = true


func _on_turn_over() -> void:
	colorrect.visible = Globals.turn == white

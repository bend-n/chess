extends TabContainer

var moves := PoolStringArray()
var color := true

export(bool) var color_config := true

signal back
signal done(color, moves)

export(ButtonGroup) var button_group: ButtonGroup


func _ready():
	if not color_config:
		$"".queue_free()
	button_group.connect("pressed", self, "_button_pressed")


func _button_pressed(button: BarTextureButton) -> void:
	color = button.name == "White"


func _on_Continue_pressed():
	if color_config:
		emit_signal("done", color, moves)
	else:
		emit_signal("done", moves)
	reset()


func _on_Stop_pressed():
	emit_signal("back")
	reset()


func reset():
	moves = []
	color = true
	$"%PgnInput".text = ""
	hide()


func _on_pgn_selected(_moves: PoolStringArray):
	moves = _moves

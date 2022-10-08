extends Control
class_name GameConfig

var moves := PoolStringArray()
var color := true

onready var pgn_input = $"%PgnInput"

signal back

export(ButtonGroup) var button_group: ButtonGroup


func _ready():
	button_group.connect("pressed", self, "_button_pressed")
	pgn_input.connect("pgn_selected", self, "_on_pgn_selected")


func _button_pressed(button: BarTextureButton) -> void:
	color = button.name == "White"


func _on_Stop_pressed():
	emit_signal("back")
	reset()


func reset():
	moves = []
	color = true
	pgn_input.text = ""
	hide()


func _on_pgn_selected(_moves: PoolStringArray):
	moves = _moves

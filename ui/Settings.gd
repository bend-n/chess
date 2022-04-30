extends Control

onready var piece_sets = Utils.walk_dir()
onready var piece_set_button = $ColorRect/HBoxContainer/VBoxContainer/PieceSet


func toggle(onoff):
	visible = onoff


func _ready():
	for i in piece_sets:
		piece_set_button.add_icon_item(load("res://assets/pieces/" + i + "/wP.png"), i)
	piece_set_button.selected = piece_sets.find("california")


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle(false)


func _on_BackButton_pressed():
	toggle(false)


func _on_PieceSet_item_selected(index):
	Globals.piece_set = piece_sets[index]

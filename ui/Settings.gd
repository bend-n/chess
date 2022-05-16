extends Control

onready var piece_sets := Utils.walk_dir()
onready var piece_set_button := $ColorRect/HBoxContainer/VBoxContainer/PieceSet
onready var fullscreenbutton := $ColorRect/HBoxContainer/VBoxContainer2/FullscreenButton
onready var vsyncbutton := $ColorRect/HBoxContainer/VBoxContainer2/VsyncButton
onready var borderlessbutton := $ColorRect/HBoxContainer/VBoxContainer2/Borderless

onready var settings: Dictionary = SaveLoad.files["settings"]["data"] setget set_settings


func set_settings(new_settings) -> void:
	toggle_button_visuals(new_settings)
	settings = new_settings
	SaveLoad.files["settings"]["data"] = settings
	SaveLoad.save("settings")


func toggle(onoff) -> void:
	visible = onoff


func toggle_button_visuals(set = settings) -> void:
	vsyncbutton.pressed = set["vsync"]
	fullscreenbutton.pressed = set["fullscreen"]
	borderlessbutton.pressed = !set["borderless"]
	piece_set_button.selected = Array(piece_sets).find(settings.piece_set)


func _ready() -> void:
	for i in piece_sets:  # add the items
		piece_set_button.add_icon_item(load("res://assets/pieces/" + i + "/wP.png"), i)
	toggle_button_visuals()
	Globals.piece_set = piece_sets[piece_set_button.selected]


func _input(event) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		toggle(false)


func _on_BackButton_pressed() -> void:
	toggle(false)


func _on_PieceSet_item_selected(index) -> void:
	Globals.piece_set = piece_sets[index]
	self.settings.piece_set = piece_sets[index]


func _on_VsyncButton_toggled(button_pressed: bool) -> void:
	OS.vsync_enabled = button_pressed
	self.settings.vsync = button_pressed


func _on_FullscreenButton_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed
	self.settings.fullscreen = button_pressed


func _on_Borderless_toggled(button_pressed: bool) -> void:
	self.settings.borderless = !button_pressed
	OS.window_borderless = !button_pressed

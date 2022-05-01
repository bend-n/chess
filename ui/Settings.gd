extends Control

onready var piece_sets: Array = Utils.walk_dir()
onready var piece_set_button := $ColorRect/HBoxContainer/VBoxContainer/PieceSet
onready var fullscreenbutton := $ColorRect/HBoxContainer/VBoxContainer2/FullscreenButton
onready var vsyncbutton := $ColorRect/HBoxContainer/VBoxContainer2/VsyncButton
onready var borderlessbutton := $ColorRect/HBoxContainer/VBoxContainer2/Borderless

var settings := {"vsync": OS.vsync_enabled, "fullscreen": OS.window_fullscreen, "borderless": OS.window_borderless} setget set_settings


func set_settings(new_settings):
	toggle_button_visuals(new_settings)
	settings = new_settings


func toggle(onoff):
	visible = onoff


func toggle_button_visuals(set = settings):
	vsyncbutton.pressed = set["vsync"]
	fullscreenbutton.pressed = set["fullscreen"]
	borderlessbutton.pressed = !set["borderless"]


func _ready():
	toggle_button_visuals()
	for i in piece_sets:
		piece_set_button.add_icon_item(load("res://assets/pieces/" + i + "/wP.png"), i)
	piece_set_button.selected = 0


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle(false)


func _on_BackButton_pressed():
	toggle(false)


func _on_PieceSet_item_selected(index):
	Globals.piece_set = piece_sets[index]


func _on_VsyncButton_toggled(button_pressed: bool):
	OS.vsync_enabled = button_pressed
	self.settings.vsync = button_pressed


func _on_FullscreenButton_toggled(button_pressed: bool):
	OS.window_fullscreen = button_pressed
	self.settings.fullscreen = button_pressed


func _on_Borderless_toggled(button_pressed: bool):
	self.settings.borderless = !button_pressed
	OS.window_borderless = !button_pressed

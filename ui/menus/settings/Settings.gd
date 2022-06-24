extends Control

onready var piece_sets := Utils.walk_dir()
onready var piece_set_button: GridMenuButton = find_node("PieceSet")
onready var fullscreenbutton := find_node("FullscreenButton")
onready var vsyncbutton := find_node("VsyncButton")
onready var borderlessbutton := find_node("Borderless")
onready var preview: Preview = find_node("Preview")
onready var board_color1: ColorPickerButtonBetter = find_node("boardcolor1")
onready var board_color2: ColorPickerButtonBetter = find_node("boardcolor2")
onready var rainbow = find_node("rainbow")

onready var settings: Dictionary = SaveLoad.get_data("settings") setget set_settings

var ignore_set_settings = false


func set_settings(new_settings: Dictionary) -> void:
	if ignore_set_settings:
		return
	update_button_visuals(new_settings)
	settings = new_settings
	SaveLoad.files["settings"]["data"] = settings
	SaveLoad.save("settings")


func update_button_visuals(set: Dictionary = settings) -> void:
	ignore_set_settings = true
	vsyncbutton.pressed = set["vsync"]
	fullscreenbutton.pressed = set["fullscreen"]
	if is_instance_valid(borderlessbutton):
		borderlessbutton.pressed = !set["borderless"]
	board_color1.color = set["board_color1"]
	board_color2.color = set["board_color2"]
	rainbow.pressed = set["rainbow"]
	preview.update_preview(set["board_color1"], set["board_color2"], set["piece_set"])
	ignore_set_settings = false


func _ready() -> void:
	if OS.has_feature("HTML5"):
		borderlessbutton.queue_free()
	for i in piece_sets:  # add the items
		piece_set_button.add_icon_item(load("res://assets/pieces/" + i + "/wP.png"), i, Vector2(50, 50))
	piece_set_button.selected = Array(piece_sets).find(settings.piece_set)
	update_vars()
	update_button_visuals()


func update_vars() -> void:
	Globals.piece_set = settings.piece_set
	Globals.board_color1 = settings.board_color1
	Globals.board_color2 = settings.board_color2
	OS.vsync_enabled = settings.vsync
	OS.window_fullscreen = settings.fullscreen
	OS.window_borderless = settings.borderless
	ColorBack.rainbow = settings.rainbow
	SaveLoad.files["settings"]["data"] = settings
	SaveLoad.save("settings")


func _on_PieceSet_selected(index: int) -> void:
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


func _on_boardcolor1_newcolor(color: Color) -> void:
	Globals.board_color1 = color
	self.settings.board_color1 = color


func _on_boardcolor2_newcolor(color: Color) -> void:
	Globals.board_color2 = color
	self.settings.board_color2 = color


func _on_resetbutton_pressed() -> void:
	self.settings = SaveLoad.default_settings_data.duplicate(true)
	update_vars()


func _on_rainbow_toggled(button_pressed: bool) -> void:
	ColorBack.rainbow = button_pressed
	self.settings.rainbow = button_pressed

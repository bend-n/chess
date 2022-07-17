extends Control

const file = "user://chess.settings"

onready var piece_sets: PoolStringArray = Utils.walk_dir()
onready var piece_set_button: GridMenuButton = find_node("PieceSet")
onready var fullscreenbutton := find_node("FullscreenButton")
onready var vsyncbutton := find_node("VsyncButton")
onready var borderlessbutton := find_node("Borderless")
onready var preview: Preview = find_node("Preview")
onready var board_color1: ColorPickerButtonBetter = find_node("boardcolor1")
onready var board_color2: ColorPickerButtonBetter = find_node("boardcolor2")
onready var rainbow = find_node("rainbow")

onready var settings: Dictionary = default_settings_data setget set_settings

const default_settings_data := {
	vsync = false,
	fullscreen = false,
	borderless = false,
	piece_set = "california",
	board_color1 = Color(0.870588, 0.890196, 0.901961),
	board_color2 = Color(0.54902, 0.635294, 0.678431),
	rainbow = false
}

var ignore_set_settings = false


func set_settings(new_settings: Dictionary) -> void:
	if not ignore_set_settings:
		update_button_visuals(new_settings)
		settings = new_settings
		SaveLoad.save(file, settings)


func update_button_visuals(set: Dictionary = settings) -> void:
	ignore_set_settings = true
	vsyncbutton.pressed = set.vsync
	fullscreenbutton.pressed = set.fullscreen
	if is_instance_valid(borderlessbutton):
		borderlessbutton.pressed = !set.borderless
	board_color1.color = set.board_color1
	board_color2.color = set.board_color2
	rainbow.pressed = set.rainbow
	preview.update_preview(set.board_color1, set.board_color2, set.piece_set)
	ignore_set_settings = false


func _ready() -> void:
	var lod = SaveLoad.load(file)
	settings = lod if Utils.dict_cmp(lod, default_settings_data) else default_settings_data
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
	SaveLoad.save(file, settings)


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


func _on_boardcolor1_changed(color: Color):
	preview.update_preview(color, settings.board_color2, settings.piece_set)


func _on_boardcolor2_newcolor(color: Color) -> void:
	Globals.board_color2 = color
	self.settings.board_color2 = color


func _on_boardcolor2_changed(color: Color):
	preview.update_preview(settings.board_color1, color, settings.piece_set)


func _on_resetbutton_pressed() -> void:
	self.settings = default_settings_data.duplicate()
	update_vars()


func _on_rainbow_toggled(button_pressed: bool) -> void:
	ColorBack.rainbow = button_pressed
	self.settings.rainbow = button_pressed

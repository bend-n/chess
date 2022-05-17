extends Node
class_name SaveLoader

const settings_file := "user://chess.settings"

const default_settings_data = {
	"vsync": OS.vsync_enabled,
	"fullscreen": OS.window_fullscreen,
	"borderless": OS.window_borderless,
	"piece_set": "california",
	"board_color1": Color(0.870588, 0.890196, 0.901961),
	"board_color2": Color(0.54902, 0.635294, 0.678431)
}

var files := {"settings": {"file": settings_file, "data": default_settings_data.duplicate(true)}}  # file types


func _ready():
	SaveLoad.load_data("settings")


func save(type) -> void:
	var file = File.new()
	file.open(files[type]["file"], File.WRITE)
	file.store_string(var2str(files[type]["data"]))


func load_data(type: String) -> Dictionary:
	if check_file(type):
		var file = File.new()
		file.open(files[type]["file"], File.READ)
		if file.get_as_text().length() > 0:
			var read_dictionary: Dictionary = str2var(file.get_as_text())
			if files[type]["data"].size() == read_dictionary.size():
				files[type]["data"] = read_dictionary
		file.close()
	return files[type]["data"]


func check_file(type) -> bool:
	var file = File.new()
	return file.file_exists(files[type]["file"])

extends Node
class_name SaveLoader

const settings_file := "user://chess.settings"
const id := "user://.chess.id"

const default_settings_data = {
	"vsync": OS.vsync_enabled,
	"fullscreen": OS.window_fullscreen,
	"borderless": OS.window_borderless,
	"piece_set": "california",
	"board_color1": Color(0.870588, 0.890196, 0.901961),
	"board_color2": Color(0.54902, 0.635294, 0.678431),
	"rainbow": true
}

var files := {
	"settings": {"file": settings_file, "data": default_settings_data.duplicate(true)},
	"id": {"file": id, "data": {"id": "", "name": "", "country": "rainbow", "password": ""}}
}  # file types


func _ready() -> void:
	# Debug.monitor(self, "id data", "files.id.data")
	SaveLoad.load_data("settings")
	SaveLoad.load_data("id")


func to_base64(variant) -> String:
	return Marshalls.variant_to_base64(variant)


func from_base64(base64):
	return Marshalls.base64_to_variant(base64)


func save(type: String) -> void:
	var file := File.new()
	file.open(files[type]["file"], File.WRITE)
	file.store_string(to_base64(files[type]["data"]))


func load_data(type: String) -> Dictionary:
	if check_file(type):
		var file := File.new()
		file.open(files[type]["file"], File.READ)
		var text = file.get_as_text()
		if len(text) > 0:
			var read_dictionary = from_base64(text)
			if typeof(read_dictionary) != TYPE_DICTIONARY:
				save(type)  # OVERWRITE
			elif files[type]["data"].keys() == read_dictionary.keys():
				files[type]["data"] = read_dictionary
		save(type)  # overwrite.
		file.close()
	else:
		save(type)
	return files[type]["data"]


func check_file(type: String) -> bool:
	var file := File.new()
	return file.file_exists(files[type]["file"])

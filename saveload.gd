extends Node
class_name SaveLoader

const settings_file := "user://chess.settings"
const id := "user://.chess.id"

var file: File = File.new()

const default_settings_data = {
	vsync = OS.vsync_enabled,
	fullscreen = OS.window_fullscreen,
	borderless = OS.window_borderless,
	piece_set = "california",
	board_color1 = Color(0.870588, 0.890196, 0.901961),
	board_color2 = Color(0.54902, 0.635294, 0.678431),
	rainbow = false
}

const default_id_data = {id = "", name = "", country = "rainbow", password = ""}

var files := {
	settings = {file = settings_file, data = default_settings_data.duplicate(true)},
	id = {file = id, data = default_id_data.duplicate()}
}  # file types


func get_public_info():
	return {name = files.id.data.name, country = files.id.data.country, id = files.id.data.id}


func get_data(type: String) -> Dictionary:
	if !files.has(type):
		return {}
	return files[type].data


func _ready() -> void:
	SaveLoad.load_data("settings")
	SaveLoad.load_data("id")


static func to_base64(variant) -> String:
	return Marshalls.variant_to_base64(variant)


static func from_base64(base64: String):
	return Marshalls.base64_to_variant(base64)


func save(type: String) -> void:
	save_dict(files[type]["file"], files[type]["data"])


func save_dict(path: String, data: Dictionary, plain := false) -> void:
	file.open(path, File.WRITE)
	file.store_string(var2str(data) if plain else to_base64(data))
	file.close()


func save_string(path: String, string: String) -> void:
	file.open(path, File.WRITE)
	file.store_string(string)
	file.close()


func append_string(path: String, string: String) -> void:
	file.open(path, File.READ_WRITE)
	file.seek_end()
	file.store_string("\n%s" % string)
	file.close()


func load_string(path: String) -> String:
	if file.file_exists(path):
		file.open(path, File.READ)
		var string = file.get_as_text()
		file.close()
		return string
	return ""


func load_data(type: String) -> Dictionary:
	var read_dictionary = load_file(files[type]["file"])
	if files[type]["data"].keys() == read_dictionary.keys():
		files[type]["data"] = read_dictionary
	save(type)  # write over old data
	return files[type]["data"]


func load_file(path: String) -> Dictionary:
	if file.file_exists(path):
		file.open(path, File.READ)
		var text := file.get_as_text()
		var dict := {}
		if text:
			var read_dict = str2var(text)
			if typeof(read_dict) == TYPE_DICTIONARY:  # it may be plaintext
				dict = read_dict
			else:
				dict = from_base64(text)
		file.close()
		return dict
	return {}


func check_file(type: String) -> bool:
	return file.file_exists(files[type]["file"])

extends Node
class_name SaveLoader

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


static func to_base64(variant) -> String:
	return Marshalls.variant_to_base64(variant)


static func from_base64(base64: String):
	return Marshalls.base64_to_variant(base64)


func save(path: String, data: Dictionary, plain := true) -> void:
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
	save_string(path, "")  # create file if it doesn't exist
	return ""


func load(path: String) -> Dictionary:
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
	save(path, {})  # create file if it doesn't exist
	return {}

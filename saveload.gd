extends Node

const settings_file = "user://chess.settings"

var files := {
	"settings":
	{  # file types
		"file": settings_file,
		"data":
		{
			"vsync": OS.vsync_enabled,
			"fullscreen": OS.window_fullscreen,
			"borderless": OS.window_borderless,
			"piece_set": "california"
		}
	}
}


func _ready():
	load_data("settings")


func save(type):
	var file = File.new()
	file.open(files[type]["file"], File.WRITE)
	file.store_string(var2str(files[type]["data"]))


func load_data(type: String):
	if check_file(type):
		var file = File.new()
		file.open(files[type]["file"], File.READ)
		if file.get_as_text().length() > 0:
			var read_dictionary: Dictionary = str2var(file.get_as_text())
			if files[type]["data"].size() == read_dictionary.size():
				files[type]["data"] = read_dictionary
		file.close()


func check_file(type):
	var file = File.new()
	return file.file_exists(files[type]["file"])

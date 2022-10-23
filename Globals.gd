extends Node

var team := "w"
var spectating := false
var local: LocalMultiplayer = null
var playing := false setget , get_playing
var chat: Chat = null
var grid: Grid = null

# config vars
var piece_set: String = Settings.default_settings_data.piece_set
var board_color1: Color = Settings.default_settings_data.board_color1
var board_color2: Color = Settings.default_settings_data.board_color2
var premoves: bool = Settings.default_settings_data.premoves


func reset_vars() -> void:
	team = "w"
	grid = null
	chat = null
	local = null
	spectating = false


func get_playing() -> bool:
	return has_node("/root/Game")


func _ready() -> void:
	Log.info("startup")
	VisualServer.set_default_clear_color(Color.black)
	Debug.monitor(self, "static memory", "get_static_memory()")
	Debug.monitor(self, "dynamic memory", "get_dynamic_memory()")
	Debug.monitor(Engine, "fps", "get_frames_per_second()")


func get_static_memory() -> String:
	return String.humanize_size(OS.get_static_memory_usage())


func get_dynamic_memory() -> String:
	return String.humanize_size(OS.get_dynamic_memory_usage())

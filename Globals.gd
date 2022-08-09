extends Node

var team := "w"
var piece_set := "california"
var board_color1: Color = Color(0.870588, 0.890196, 0.901961)
var board_color2: Color = Color(0.54902, 0.635294, 0.678431)
var spectating := false
var playing := false setget , get_playing
var chat: Chat = null
var grid: Grid = null


func reset_vars() -> void:
	team = "w"
	grid = null
	chat = null
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

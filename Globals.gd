extends Node

var __nosethalfmove := false
var pawns := []  # PoolPawnArray
var team := true
var grid: Grid = null
var network: Network = null
var piece_set := "california"
var fullmove := 1
var halfmove := 0
var in_check := false
var checking_piece: Piece = null
var board_color1: Color = Color(0.870588, 0.890196, 0.901961)
var board_color2: Color = Color(0.54902, 0.635294, 0.678431)
var white_king: King = null
var black_king: King = null
var spectating := false
var chat: Chat = null
var turn := true  # true for white, false for black
# true cuz white goes first


func reset_vars() -> void:
	__nosethalfmove = false
	pawns = []
	team = true
	spectating = false
	grid = null
	fullmove = 1
	halfmove = 0
	in_check = false
	checking_piece = null
	white_king = null
	black_king = null
	turn = true
	Utils.reset_vars()


func reset_halfmove() -> void:
	halfmove = 0
	__nosethalfmove = true


func add_turn() -> void:
	Events.emit_signal("just_before_turn_over")
	turn = not turn
	if turn:  #  white just moved
		fullmove += 1
	if __nosethalfmove:
		__nosethalfmove = false
	else:
		halfmove += 1
	Events.emit_signal("turn_over")


func get_turn() -> String:
	return "white" if turn else "black"


func get_team() -> String:
	return "white" if team else "black"


func _ready() -> void:
	VisualServer.set_default_clear_color(Color.black)
	Debug.monitor(self, "fullmove")
	Debug.monitor(self, "halfmove")
	Debug.monitor(self, "in_check")
	Debug.monitor(self, "turn", "get_turn()")
	Debug.monitor(self, "team", "get_team()")
	Debug.monitor(self, "static memory", "get_static_memory()")
	Debug.monitor(self, "dynamic memory", "get_dynamic_memory()")
	Debug.monitor(Engine, "fps", "get_frames_per_second()")


func get_static_memory() -> String:
	return String.humanize_size(OS.get_static_memory_usage())


func get_dynamic_memory() -> String:
	return String.humanize_size(OS.get_dynamic_memory_usage())

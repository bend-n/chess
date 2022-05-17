extends Node

var __nosethalfmove = false
var pawns = []  # PoolPawnArray
var team = true
var grid: Grid = null
var network: Network = null
var piece_set := "california"
var fullmove := 1
var halfmove := 0
var in_check := false
var checking_piece: Piece = null
var board_color1: Color
var board_color2: Color
var white_king: King
var black_king: King
var turn := true  # true for white, false for black
# true cuz white goes first


func reset_vars() -> void:
	__nosethalfmove = false
	pawns = []
	team = true
	grid = null
	fullmove = 1
	halfmove = 0
	in_check = false
	checking_piece = null
	white_king = null
	black_king = null
	turn = true
	Utils.reset_vars()


func pack_vars() -> Dictionary:
	return {
		"fullmove": fullmove,
		"halfmove": halfmove,
		"turn": turn,
	}


func get_var(key):
	return self.get(key)


func turns() -> int:
	return fullmove


func reset_halfmove() -> void:
	halfmove = 0
	__nosethalfmove = true


func add_turn() -> void:
	Events.emit_signal("just_before_turn_over")
	if !turn:
		fullmove += 1
	if __nosethalfmove:
		__nosethalfmove = false
	else:
		halfmove += 1
	turn = not turn
	Events.emit_signal("turn_over")


func _ready() -> void:
	VisualServer.set_default_clear_color(Color.black)

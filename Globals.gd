extends Node

var __nosethalfmove = false

var pawns = []  # PoolPawnArray
var grid: Grid = null
var piece_set := "california"
var fullmove := 1
var halfmove := 0
var in_check := false
var checking_piece: Piece = null
var white_king: King
var black_king: King
var turn := true  # true for white, false for black
# true cuz white goes first


func turns(_winner) -> int:
	return fullmove


func reset_halfmove() -> void:
	halfmove = 0
	__nosethalfmove = true


func add_turn() -> void:
	if !turn:
		fullmove += 1
	if __nosethalfmove:
		__nosethalfmove = false
		return
	halfmove += 1


func _ready() -> void:
	VisualServer.set_default_clear_color(Color.black)

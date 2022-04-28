extends Node

var grid: Grid = null
var white_turns := 0
var black_turns := 0
var in_check = false
var checking_piece: Piece = null
var white_king: King
var black_king: King
var turn := true  # true for white, false for black
# true cuz white goes first


func turns(winner):
	if winner == "white":
		return white_turns
	elif winner == "black":
		return black_turns


func add_turn():
	if turn:
		white_turns += 1
	else:
		black_turns += 1

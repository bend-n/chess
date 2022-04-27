extends Node

var grid: Grid = null
var turns := 0
var in_check = false
var checking_piece: Piece = null
var white_king: King
var black_king: King
var turn := true  # true for white, false for black
# true cuz white goes first

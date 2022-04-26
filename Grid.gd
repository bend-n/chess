extends Node2D
class_name Grid

export var PIECE_SET = "california"

export(Color) var board_color1 = Color(0.870588, 0.890196, 0.901961)
export(Color) var board_color2 = Color(0.54902, 0.635294, 0.678431)
export(Color) var overlay_color = Color(0.2, 0.345098, 0.188235, 0.592157)

onready var background = $Background

onready var ASSETS_PATH = "res://assets/" + PIECE_SET + "/"

const Piece = preload("res://Piece.tscn")
const Square = preload("res://Square.tscn")

const piece_size = Vector2(100, 100)

var matrix = []
var background_matrix = []
var last_clicked


func _ready():
	print(PIECE_SET)
	Globals.grid = self
	init_board()
	init_matrix()
	Events.connect("turn_over", self, "_on_turn_over")


func _on_turn_over():
	for i in range(0, 8):
		for j in range(0, 8):
			var spot = matrix[i][j]
			if spot and spot.white != Globals.turn:  # enemie
				if matrix[i][j].create_circles(false):
					print("woaw")


func _exit_tree():
	Globals.grid = null


func init_matrix():
	for i in range(8):
		matrix.append([])
		for _j in range(8):
			matrix[i].append(null)
	add_pieces()


func instance_piece_at_position(position: Vector2, name: String, sprite: String, white: bool = true):
	var piece = Piece.instance()
	piece.sprite = piece.get_node("Sprite")
	piece.sprite.texture = load(sprite)
	piece.real_position = position
	position *= piece_size
	piece.global_position = position
	piece.realname = name
	piece.name = name
	piece.white = white
	add_child(piece)
	return piece


func init_board():
	for i in range(8):
		background_matrix.append([])
		for j in range(8):
			# var square = ColorRect.new()
			var square = Square.instance()
			square.rect_size = piece_size
			square.rect_position = Vector2(i, j) * piece_size
			square.realname = "square_" + str(i) + "_" + str(j)
			square.color = board_color1 if (i + j) % 2 == 0 else board_color2
			square.real_position = Vector2(i, j)
			background.add_child(square)
			square.connect("clicked", self, "square_clicked")
			background_matrix[i].append(square)


func add_pieces():
	add_pawns()
	add_rooks()
	add_knights()
	add_bishops()
	add_queens()
	add_kings()
	print_matrix_pretty()


func add_pawns():
	for i in range(8):
		matrix[1][i] = instance_piece_at_position(Vector2(i, 1), "pawn", ASSETS_PATH + "bP.png", false)
		matrix[6][i] = instance_piece_at_position(Vector2(i, 6), "pawn", ASSETS_PATH + "wP.png", true)


func add_rooks():
	matrix[0][0] = instance_piece_at_position(Vector2(0, 0), "rook", ASSETS_PATH + "bR.png", false)
	matrix[0][7] = instance_piece_at_position(Vector2(7, 0), "rook", ASSETS_PATH + "bR.png", false)
	matrix[7][0] = instance_piece_at_position(Vector2(0, 7), "rook", ASSETS_PATH + "wR.png", true)
	matrix[7][7] = instance_piece_at_position(Vector2(7, 7), "rook", ASSETS_PATH + "wR.png", true)


func add_knights():
	matrix[0][1] = instance_piece_at_position(Vector2(1, 0), "knight", ASSETS_PATH + "bN.png", false)
	matrix[0][6] = instance_piece_at_position(Vector2(6, 0), "knight", ASSETS_PATH + "bN.png", false)
	matrix[7][1] = instance_piece_at_position(Vector2(1, 7), "knight", ASSETS_PATH + "wN.png", true)
	matrix[7][6] = instance_piece_at_position(Vector2(6, 7), "knight", ASSETS_PATH + "wN.png", true)


func add_bishops():
	matrix[0][2] = instance_piece_at_position(Vector2(2, 0), "bishop", ASSETS_PATH + "bB.png", false)
	matrix[0][5] = instance_piece_at_position(Vector2(5, 0), "bishop", ASSETS_PATH + "bB.png", false)
	matrix[7][2] = instance_piece_at_position(Vector2(2, 7), "bishop", ASSETS_PATH + "wB.png", true)
	matrix[7][5] = instance_piece_at_position(Vector2(5, 7), "bishop", ASSETS_PATH + "wB.png", true)


func add_queens():
	matrix[0][3] = instance_piece_at_position(Vector2(3, 0), "queen", ASSETS_PATH + "bQ.png", false)
	matrix[7][3] = instance_piece_at_position(Vector2(3, 7), "queen", ASSETS_PATH + "wQ.png", true)


func add_kings():
	matrix[0][4] = instance_piece_at_position(Vector2(4, 0), "king", ASSETS_PATH + "bK.png", false)
	matrix[7][4] = instance_piece_at_position(Vector2(4, 7), "king", ASSETS_PATH + "wK.png", true)


func print_matrix_pretty(mat = matrix):
	print("[")
	for r in mat:
		var row = "	["
		for i in range(8):
			var c = r[i]
			var ender = ", " if i < 7 else ""
			if c:
				row += c.realname + ender
			else:
				row += "null" + ender
		print(row + "],")
	print("]")


func check_for_circle(position: Vector2):
	return background_matrix[position.x][position.y].circle_on


func check_for_frame(position: Vector2):
	if !matrix[position.y][position.x]:
		return false
	return matrix[position.y][position.x].frameon


func square_clicked(position: Vector2):
	var spot = matrix[position.y][position.x]
	if !spot or spot.white != Globals.turn:  # spot is not a tile or spot is not turn color
		if !last_clicked:  # last clicked is null, so this is pointless
			return
		if check_for_circle(position):  # see if theres a circle at the position
			last_clicked.moveto(position)  # if there is, move there
		if check_for_frame(position):  # takeable
			last_clicked.take(matrix[position.y][position.x])  # eat
		last_clicked.clear_clicked()  # remove the circles
		last_clicked = null  # set it to null
	elif last_clicked != spot:  # we got a new piece (or pawn) clicked
		if last_clicked:  # remove the circles
			last_clicked.clear_clicked()
		last_clicked = spot  # set it to the new spot
		spot.clicked()  # tell the piece shit happeend


func clear_circles():
	for i in range(8):
		for j in range(8):
			var square = background_matrix[i][j]
			square.set_circle(false)


func clear_frames():
	for i in range(8):
		for j in range(8):
			var square = matrix[i][j]
			if square:
				square.set_frame(false)


func _input(event):
	if event.is_action("debug"):
		print_matrix_pretty()

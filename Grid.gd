extends Node2D

export var PIECE_SET = "california"

export(Color) var board_color1 = Color.white
export(Color) var board_color2 = Color.black
export(Color) var overlay_color = Color(0.2, 0.345098, 0.188235, 0.592157)

onready var background = $Background

var ASSETS_PATH = "res://assets/" + PIECE_SET + "/"

const Piece = preload("res://Piece.tscn")
const Square = preload("res://Square.tscn")

const piece_size = Vector2(100, 100)

var matrix = []
var background_matrix = []
var last_clicked


func _ready():
	Globals.grid = self
	init_board()
	init_matrix()


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
	print_matrix_pretty(background_matrix)


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
		matrix[1][i] = instance_piece_at_position(
			Vector2(i, 1), "pawn", ASSETS_PATH + "bP.png", false
		)
		matrix[6][i] = instance_piece_at_position(
			Vector2(i, 6), "pawn", ASSETS_PATH + "wP.png", true
		)


func add_rooks():
	matrix[0][0] = instance_piece_at_position(Vector2(0, 0), "rook", ASSETS_PATH + "bR.png", false)
	matrix[0][7] = instance_piece_at_position(Vector2(7, 0), "rook", ASSETS_PATH + "bR.png", false)
	matrix[7][0] = instance_piece_at_position(Vector2(0, 7), "rook", ASSETS_PATH + "wR.png", true)
	matrix[7][7] = instance_piece_at_position(Vector2(7, 7), "rook", ASSETS_PATH + "wR.png", true)


func add_knights():
	matrix[0][1] = instance_piece_at_position(
		Vector2(1, 0), "knight", ASSETS_PATH + "bN.png", false
	)
	matrix[0][6] = instance_piece_at_position(
		Vector2(6, 0), "knight", ASSETS_PATH + "bN.png", false
	)
	matrix[7][1] = instance_piece_at_position(Vector2(1, 7), "knight", ASSETS_PATH + "wN.png", true)
	matrix[7][6] = instance_piece_at_position(Vector2(6, 7), "knight", ASSETS_PATH + "wN.png", true)


func add_bishops():
	matrix[0][2] = instance_piece_at_position(
		Vector2(2, 0), "bishop", ASSETS_PATH + "bB.png", false
	)
	matrix[0][5] = instance_piece_at_position(
		Vector2(5, 0), "bishop", ASSETS_PATH + "bB.png", false
	)
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
	var circle = background_matrix[position.x][position.y].circle.visible
	return circle


func square_clicked(position: Vector2):
	var spot = matrix[position.y][position.x]
	if !spot or !spot.white:
		if !last_clicked:  # its null
			return
		if check_for_circle(position):
			last_clicked.moveto(position)
		last_clicked.clear_clicked()
		last_clicked = null
	elif last_clicked != spot:
		if last_clicked:
			last_clicked.clear_clicked()
		last_clicked = spot
		spot.clicked()


func clear_circles():
	for i in range(8):
		for j in range(8):
			var square = background_matrix[i][j]
			square.set_circle(false)

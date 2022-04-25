extends Node2D

export var PIECE_SET = "california"

export(Color) var board_color1 = Color.white
export(Color) var board_color2 = Color.black

onready var background = $Background

var ASSETS_PATH = "res://assets/" + PIECE_SET + "/"

const Piece = preload("res://Piece.tscn")
const Square = preload("res://Square.tscn")

const piece_size = Vector2(100, 100)

var matrix = []
var background_matrix = []

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
	# piece.sprite.flip_v = not white # this is not shogi you eejit
	if white:
		position -= Vector2(0, piece_size.y)  # boost it up
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
			square.name = "square_" + str(i) + "_" + str(j)
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
		matrix[1][i] = instance_piece_at_position(
			Vector2(i, 1) * piece_size, "pawn", ASSETS_PATH + "bP.png", false
		)
		matrix[6][i] = instance_piece_at_position(
			Vector2(i, 7) * piece_size, "pawn", ASSETS_PATH + "wP.png", true
		)


func add_rooks():
	matrix[0][0] = instance_piece_at_position(
		Vector2(0, 0) * piece_size, "rook", ASSETS_PATH + "bR.png", false
	)
	matrix[0][7] = instance_piece_at_position(
		Vector2(7, 0) * piece_size, "rook", ASSETS_PATH + "bR.png", false
	)
	matrix[7][0] = instance_piece_at_position(
		Vector2(0, 8) * piece_size, "rook", ASSETS_PATH + "wR.png", true
	)
	matrix[7][7] = instance_piece_at_position(
		Vector2(7, 8) * piece_size, "rook", ASSETS_PATH + "wR.png", true
	)


func add_knights():
	matrix[0][1] = instance_piece_at_position(
		Vector2(1, 0) * piece_size, "knight", ASSETS_PATH + "bN.png", false
	)
	matrix[0][6] = instance_piece_at_position(
		Vector2(6, 0) * piece_size, "knight", ASSETS_PATH + "bN.png", false
	)
	matrix[7][1] = instance_piece_at_position(
		Vector2(1, 8) * piece_size, "knight", ASSETS_PATH + "wN.png", true
	)
	matrix[7][6] = instance_piece_at_position(
		Vector2(6, 8) * piece_size, "knight", ASSETS_PATH + "wN.png", true
	)


func add_bishops():
	matrix[0][2] = instance_piece_at_position(
		Vector2(2, 0) * piece_size, "bishop", ASSETS_PATH + "bB.png", false
	)
	matrix[0][5] = instance_piece_at_position(
		Vector2(5, 0) * piece_size, "bishop", ASSETS_PATH + "bB.png", false
	)
	matrix[7][2] = instance_piece_at_position(
		Vector2(2, 8) * piece_size, "bishop", ASSETS_PATH + "wB.png", true
	)
	matrix[7][5] = instance_piece_at_position(
		Vector2(5, 8) * piece_size, "bishop", ASSETS_PATH + "wB.png", true
	)


func add_queens():
	matrix[0][3] = instance_piece_at_position(
		Vector2(3, 0) * piece_size, "queen", ASSETS_PATH + "bQ.png", false
	)
	matrix[7][3] = instance_piece_at_position(
		Vector2(3, 8) * piece_size, "queen", ASSETS_PATH + "wQ.png", true
	)


func add_kings():
	matrix[0][4] = instance_piece_at_position(
		Vector2(4, 0) * piece_size, "king", ASSETS_PATH + "bK.png", false
	)
	matrix[7][4] = instance_piece_at_position(
		Vector2(4, 8) * piece_size, "king", ASSETS_PATH + "wK.png", true
	)


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


func _ready():
	Globals.piece_size = piece_size
	init_board()
	init_matrix()


func square_clicked(position: Vector2):
	var spot = matrix[position.y][position.x]
	if !spot:
		print("spot isnt null")
		if !Globals.last_clicked: # its null
			print("last clicked is null")
			return
		print("last clicked wasnt null")
		Globals.last_clicked.spot(position)
		Globals.last_clicked = null
	elif Globals.last_clicked != spot:
		print("last clicked is different")
		if Globals.last_clicked:
			Globals.last_clicked.spot(null)
		Globals.last_clicked = spot
		spot.clicked()


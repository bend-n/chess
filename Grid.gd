extends Node2D
class_name Grid

export var PIECE_SET = "california"

export(Color) var board_color1 = Color(0.870588, 0.890196, 0.901961)
export(Color) var board_color2 = Color(0.54902, 0.635294, 0.678431)
export(Color) var overlay_color = Color(0.2, 0.345098, 0.188235, 0.592157)

const Piece = preload("res://Piece.tscn")
const Square = preload("res://Square.tscn")
const BottomLeftLabel = preload("res://ui/BottomLeftLabel.tscn")
const TopRightLabel = preload("res://ui/TopRightLabel.tscn")

const piece_size = Vector2(100, 100)
const default_metadata = {
	"wccl": false,  # white can castle left
	"wccr": false,  # white can castle right
	"bccl": false,  # black can castle left
	"bccr": false,  # black can castle right
	"turn": true,  # true = white, false = black
	"wcep": [],  # white can enpassant
	"bcep": [],  # black can enpassant
}

var matrix = []
var background_matrix = []
var history_matrixes: Dictionary = {}

var last_clicked

onready var background = $Background
onready var ASSETS_PATH = "res://assets/" + PIECE_SET + "/"
onready var piece_sets = walk_dir()
onready var foreground = $Foreground
onready var pieces = $Pieces


func _ready():
	Globals.grid = self  # tell the globals that this is the grid
	init_board()  # create the tile squares
	init_matrix()  # create the pieces
	init_labels()
	Events.connect("turn_over", self, "_on_turn_over")  # listen for turn_over events


func init_labels():
	for i in range(8):
		var letterslabel = BottomLeftLabel.instance()
		letterslabel.rect_position.x = i * piece_size.x
		letterslabel.rect_position.y = piece_size.y * 7
		size_label(letterslabel, i)
		letterslabel.get_node("Label").text = Utils.calculate_algebraic_position(
			letterslabel.rect_position / piece_size
		)[0]
		foreground.add_child(letterslabel)
		var numberslabel = TopRightLabel.instance()
		numberslabel.rect_position.y = i * piece_size.x
		numberslabel.rect_position.x = piece_size.x * 7
		size_label(numberslabel, i)
		numberslabel.get_node("Label").text = str(8 - i)
		foreground.add_child(numberslabel)


func size_label(label, i):
	label.rect_size = piece_size
	label.get_node("Label").add_color_override("font_color", board_color1 if i % 2 == 0 else board_color2)


func threefoldrepetition():
	for i in history_matrixes.values():
		if i >= 3:
			return true
	return false


func mat2str(mat = matrix):
	var string = ""
	for y in range(8):
		string += "\n"
		for x in range(8):
			var spot = mat[y][x]
			if spot:
				string += spot.mininame
			else:
				string += "*"
		string += "\n"
	for i in mat[8].keys():  # store the metadata
		var thing = mat[8][i]
		string += i + "=" + str(thing)
		if default_metadata[i] != thing:
			string += "!"
		string += "\n"
	return string


func _on_turn_over():
	var matstr = mat2str()
	# print(matstr)
	if !history_matrixes.has(matstr):
		history_matrixes[matstr] = 1
	else:
		history_matrixes[matstr] += 1
	Globals.checking_piece = null  # reset checking_piece
	Globals.in_check = false  # reset in_check
	matrix[8] = default_metadata.duplicate()  # add the metadata to the matrix
	matrix[8].turn = Globals.turn
	check_in_check(true)  # check if in_check
	if !can_move():
		print("what")
		if Globals.in_check:
			var winner = "black" if Globals.turn else "white"
			print(winner, " won the game in ", Globals.turns(winner), " turns!")
			print("the board:")
			SoundFx.play("Victory")
			print_matrix_pretty()
			yield(get_tree().create_timer(5), "timeout")
			get_tree().reload_current_scene()
			SoundFx.play("Victory")
		else:
			print("stalemate")
			drawed()
	elif threefoldrepetition():
		print("draw by threefold repetition")
		drawed()


func drawed():
	SoundFx.play("Draw")
	print_matrix_pretty()
	yield(get_tree().create_timer(5), "timeout")
	get_tree().reload_current_scene()
	SoundFx.play("Victory")


func check_in_check(prin = false):  # check if in_check
	for i in range(0, 8):  # for each row
		for j in range(0, 8):  # for each column
			var spot = matrix[i][j]  # get the square
			if spot and spot.white != Globals.turn:  # enemie
				if spot.can_attack_piece(Globals.white_king if Globals.turn else Globals.black_king):  # if it can take the king
					if prin:
						Globals.in_check = true  # set in_check
						Globals.checking_piece = spot  # set checking_piece
						SoundFx.play("Check")
					return true  # stop at the first check found
	return false


func can_move():
	for i in range(0, 8):  # for each row
		for j in range(0, 8):  # for each column
			var spot = matrix[i][j]  # get the square
			if spot and spot.white == Globals.turn:  # fren
				if spot.can_move():
					return true
	return false


func _exit_tree():
	Globals.grid = null  # reset the globals grid when leaving tree


func init_matrix():  # create the matrix
	for i in range(8):  # for each row
		matrix.append([])  # add a row
		for _j in range(8):  # for each column
			matrix[i].append(null)  # add a square
	matrix.append(default_metadata.duplicate())  # metadata for threefold repetition check
	add_pieces()  # add the pieces


func make_piece(position: Vector2, script: String, sprite: String, white: bool = true):  # make peace
	var piece = Piece.instance()  # create a piece
	piece.script = load(script)  # set the script
	piece.sprite = piece.get_node("Sprite")  # get the sprite
	piece.sprite.texture = load(sprite)  # set the sprite
	piece.real_position = position  # set the real position
	piece.global_position = position * piece_size  # set the global position
	piece.white = white  # set its team
	pieces.add_child(piece)  # add the piece to the grid
	return piece  # return the piece


func init_board():  # create the board
	for i in range(8):  # for each row
		background_matrix.append([])  # add a row
		for j in range(8):  # for each column
			var square = Square.instance()  # create a square
			square.rect_size = piece_size  # set the size
			square.rect_position = Vector2(i, j) * piece_size  # set the position
			square.name = "square_" + str(i) + "_" + str(j)  # set the real name
			square.color = board_color1 if (i + j) % 2 == 0 else board_color2  # set the color
			square.real_position = Vector2(i, j)  # set the real position
			background.add_child(square)  # add the square to the background
			square.connect("clicked", self, "square_clicked")  # connect the clicked event
			background_matrix[i].append(square)  # add the square to the background matrix


func add_pieces():  # add the pieces
	add_pawns()
	add_rooks()
	add_knights()
	add_bishops()
	add_queens()
	add_kings()
	print_matrix_pretty()


func add_pawns():
	for i in range(8):
		matrix[1][i] = make_piece(Vector2(i, 1), "res://pieces/Pawn.gd", ASSETS_PATH + "bP.png", false)
		matrix[6][i] = make_piece(Vector2(i, 6), "res://pieces/Pawn.gd", ASSETS_PATH + "wP.png", true)


func add_rooks():
	matrix[0][0] = make_piece(Vector2(0, 0), "res://pieces/Rook.gd", ASSETS_PATH + "bR.png", false)
	matrix[0][7] = make_piece(Vector2(7, 0), "res://pieces/Rook.gd", ASSETS_PATH + "bR.png", false)
	matrix[7][0] = make_piece(Vector2(0, 7), "res://pieces/Rook.gd", ASSETS_PATH + "wR.png", true)
	matrix[7][7] = make_piece(Vector2(7, 7), "res://pieces/Rook.gd", ASSETS_PATH + "wR.png", true)


func add_knights():
	matrix[0][1] = make_piece(Vector2(1, 0), "res://pieces/Knight.gd", ASSETS_PATH + "bN.png", false)
	matrix[0][6] = make_piece(Vector2(6, 0), "res://pieces/Knight.gd", ASSETS_PATH + "bN.png", false)
	matrix[7][1] = make_piece(Vector2(1, 7), "res://pieces/Knight.gd", ASSETS_PATH + "wN.png", true)
	matrix[7][6] = make_piece(Vector2(6, 7), "res://pieces/Knight.gd", ASSETS_PATH + "wN.png", true)


func add_bishops():
	matrix[0][2] = make_piece(Vector2(2, 0), "res://pieces/Bishop.gd", ASSETS_PATH + "bB.png", false)
	matrix[0][5] = make_piece(Vector2(5, 0), "res://pieces/Bishop.gd", ASSETS_PATH + "bB.png", false)
	matrix[7][2] = make_piece(Vector2(2, 7), "res://pieces/Bishop.gd", ASSETS_PATH + "wB.png", true)
	matrix[7][5] = make_piece(Vector2(5, 7), "res://pieces/Bishop.gd", ASSETS_PATH + "wB.png", true)


func add_queens():
	matrix[0][3] = make_piece(Vector2(3, 0), "res://pieces/Queen.gd", ASSETS_PATH + "bQ.png", false)
	matrix[7][3] = make_piece(Vector2(3, 7), "res://pieces/Queen.gd", ASSETS_PATH + "wQ.png", true)


func add_kings():
	matrix[0][4] = make_piece(Vector2(4, 0), "res://pieces/King.gd", ASSETS_PATH + "bK.png", false)
	matrix[7][4] = make_piece(Vector2(4, 7), "res://pieces/King.gd", ASSETS_PATH + "wK.png", true)
	Globals.white_king = matrix[7][4]  # set the white king
	Globals.black_king = matrix[0][4]  # set the black king


const topper_header = "┏━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┓"
const middle_header = "┣━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━┫"
const middish_heads = "┗━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━┫"
const bottom_header = "┗━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┛"
const smaller_heads = "    ┗━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┛"
const letter_header = "    ┃ a ┃ b ┃ c ┃ d ┃ e ┃ f ┃ g ┃ h ┃"
const ender = " ┃ "


func print_matrix_pretty(mat = matrix):  # print the matrix
	for j in range(8):  # for each row
		var r = mat[j]  # get the row
		if j == 0:
			print(topper_header)  # print the top border
		else:
			print(middle_header)  # print the middle border
		var row = "┃ " + str(8 - j) + " ┃ "  # init the string
		for i in range(8):  # for each column
			var c = r[i]  # get the column
			if c:  # if there is a piece
				row += c.mininame + ender  # add the shortname
			else:  # if there is no piece
				row += " " + ender  # add 00
		print(row)  # print the string
	print(middish_heads)
	print(letter_header)
	print(smaller_heads)


func check_for_circle(position: Vector2):  # check for a circle, validating movement
	return background_matrix[position.x][position.y].circle_on


func check_for_frame(position: Vector2):  # check for a frame, validating taking
	if !matrix[position.y][position.x]:  # if there is no piece
		return false  # return false
	return matrix[position.y][position.x].frameon  # return if the frame is on


func square_clicked(position: Vector2):  # square clicked
	var spot = matrix[position.y][position.x]  # get the spot
	if !spot or spot.white != Globals.turn:  # spot is not a tile or spot is not turn color
		if !last_clicked:  # last clicked is null, so this is pointless
			return
		if check_for_frame(position):  # takeable
			last_clicked.take(matrix[position.y][position.x])  # eat
			turn_over()
		if check_for_circle(position):  # see if theres a circle at the position
			handle_move(position)  # move
		last_clicked.clear_clicked()  # remove the circles
		last_clicked = null  # set it to null
	elif last_clicked != spot:  # we got a new piece (or pawn) clicked
		if last_clicked:  # remove the circles
			last_clicked.clear_clicked()
		last_clicked = spot  # set it to the new spot
		spot.clicked()  # tell the piece shit happeend


func handle_move(position):
	if last_clicked is King and last_clicked.can_castle:
		for i in range(len(last_clicked.can_castle)):
			var castle_data = last_clicked.can_castle[i]
			if castle_data[0] == position:
				Utils.add_move(last_clicked.castle(castle_data[0]))
				castle_data[1].override_moveto = true
				castle_data[1].moveto(castle_data[2])
				castle_data[1].override_moveto = false
				turn_over()
				return
	if last_clicked is Pawn and last_clicked.enpassant:
		print(last_clicked.enpassant)
		for i in range(len(last_clicked.enpassant)):
			var en_passant_data = last_clicked.enpassant[i]
			if en_passant_data[0] == position:
				en_passant_data[1].took()  # kill the unfortunate
				last_clicked.passant(en_passant_data[0])
				turn_over()
				return
	last_clicked.moveto(position)
	turn_over()


func turn_over():
	Events.emit_signal("just_before_turn_over")
	Globals.add_turn()
	Globals.turn = not Globals.turn
	Events.emit_signal("turn_over")


func clear_fx():  # clear the circles
	for i in range(8):  # for each row
		for j in range(8):  # for each column
			var square = background_matrix[i][j]  # get the square
			square.set_circle(false)  # set the circle to false
			var piece = matrix[i][j]  # get the piece
			if piece:  # if there is a piece
				piece.set_frame(false)  # clear the frame


func _input(event):  # input
	if event.is_action_released("debug"):  # if debug
		print_matrix_pretty()  # print the matrix
	if event.is_action_released("kill"):
		if last_clicked:
			last_clicked.took()  # kill the piece
			last_clicked = null
			clear_fx()  # clear the circles
	if event.is_action_released("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


func walk_dir(path = "res://assets"):  # walk the directory, finding the asset packs
	var folders = []  # init the folders
	var dir = Directory.new()  # init the directory
	if dir.open(path) == OK:  # open the directory
		dir.list_dir_begin()  # list the directory
		var file_name = dir.get_next()  # get the next file
		while file_name != "":  # while there is a file
			if dir.current_is_dir():  # if the current is a directory
				if file_name == "." or file_name == "..":  # if it is a dot or dot dot
					file_name = dir.get_next()  # get the next file
					continue
				folders.append(file_name)  # add the folder
			file_name = dir.get_next()  # get the next file
	else:
		printerr("An error occurred when trying to access the path " + path)  # print the error
	return folders  # return the folders

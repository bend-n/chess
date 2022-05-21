extends Node2D
class_name Grid

const topper_header = "┏━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┳━━━┓"
const middle_header = "┣━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━┫"
const middish_heads = "┗━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━╋━━━┫"
const bottom_header = "┗━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┛"
const smaller_heads = "    ┗━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┻━━━┛"
const letter_header = "    ┃ a ┃ b ┃ c ┃ d ┃ e ┃ f ┃ g ┃ h ┃"
const ender = " ┃ "  # for pretty prints
const Piece = preload("res://Piece.tscn")
const Square = preload("res://Square.tscn")
const BottomLeftLabel = preload("res://ui/BottomLeftLabel.tscn")
const TopRightLabel = preload("res://ui/TopRightLabel.tscn")

const piece_size := Vector2(100, 100)
const default_metadata := {
	"wccl": false,  # white can castle left
	"wccr": false,  # white can castle right
	"bccl": false,  # black can castle left
	"bccr": false,  # black can castle right
	"turn": true,  # true = white, false = black
	"wcep": [],  # white can enpassant
	"bcep": [],  # black can enpassant
}

export(Color) var overlay_color := Color(0.078431, 0.333333, 0.117647, 0.498039)
export(Color) var clockrunning_color := Color(0.219608, 0.278431, 0.133333)
export(Color) var clockrunninglow := Color(0.47451, 0.172549, 0.164706)
export(Color) var clocklow := Color(0.313726, 0.156863, 0.14902)

var matrix := []
var promoting = null
var background_matrix := []
var history_matrixes := {}
var last_clicked: Piece = null
var flipped = false

var labels = {"letters": [], "numbers": []}

onready var background := $Background
onready var ASSETS_PATH: String = "res://assets/pieces/%s/" % Globals.piece_set
onready var foreground := $Foreground
onready var pieces := $Pieces
onready var status_label := $"../UI/Holder/Back/VBox/Status"


func _init():
	Globals.grid = self


func _ready() -> void:
	init_board()  # create the tile squares
	init_matrix()  # create the pieces
	init_labels()  # add the labels
	Events.connect("turn_over", self, "_on_turn_over")  # listen for turn_over events
	Events.connect("outoftime", self, "_on_outoftime")  # listen for timeout events


func _exit_tree() -> void:
	Globals.grid = null  # reset the globals grid when leaving tree


func _input(event) -> void:  # input
	if event.is_action_released("debug"):  # if debug
		print_matrix_pretty(matrix)  # print the matrix


static func print_matrix_pretty(mat) -> void:  # print the matrix
	for j in range(8):  # for each row
		var r: Array = mat[j]  # get the row
		if j == 0:
			print(topper_header)  # print the top border
		else:
			print(middle_header)  # print the middle border
		var row = "┃ %s ┃ " % str(8 - j)  # init the string
		for i in range(8):  # for each column
			var c = r[i]  # get the column
			if c:  # if there is a piece
				row += c.mininame + ender  # add the shortname
			else:  # if there is no piece
				row += " " + ender
		print(row)  # print the string
	print("%s\n%s\n%s" % [middish_heads, letter_header, smaller_heads])


func reload_sprites() -> void:
	for i in range(8):
		for j in range(8):
			if matrix[i][j]:
				matrix[i][j].load_texture()


func flip_pieces() -> void:
	for i in range(8):
		for j in range(8):
			var spot = matrix[i][j]
			if spot:
				spot.sprite.flip_v = flipped
				spot.sprite.flip_h = flipped
				# spot.tween.interpolate_property(
				# 	spot.sprite, "rotation_degrees", spot.sprite.rotation_degrees, degree, .5
				# )
				# spot.tween.start()


func flip_labels() -> void:
	for i in range(8):
		var numlabel = labels.numbers[i].get_node("Label")
		var letlabel = labels.letters[i].get_node("Label")
		var number: int
		if flipped:
			number = i + 1
		else:
			number = 8 - i
		numlabel.text = str(number)
		letlabel.text = "hgfedcba"[number - 1]


func flip_board():
	if global_position == Vector2(800, 800):
		flipped = false
		global_position = Vector2(0, 0)
		rotation_degrees = 0
		flip_pieces()
		flip_labels()
	else:
		flipped = true
		global_position = Vector2(800, 800)
		rotation_degrees = 180
		flip_pieces()
		flip_labels()


func init_labels() -> void:
	for i in range(8):
		labels.letters.append(init_label(BottomLeftLabel, i, Vector2(i, 7), "abcdefgh"[i]))

		labels.numbers.append(init_label(TopRightLabel, i, Vector2(7, i), str(8 - i)))


func init_label(labelscene: PackedScene, i: int, position: Vector2, text: String) -> Control:
	var labelholder = labelscene.instance()
	labelholder.rect_size = piece_size
	labelholder.rect_position = position * piece_size
	var label = labelholder.get_node("Label")
	label.text = text
	label.add_color_override("font_color", Globals.board_color1 if i % 2 == 0 else Globals.board_color2)
	foreground.add_child(labelholder)
	return labelholder


func threefoldrepetition() -> bool:
	for i in history_matrixes.values():
		if i >= 3:
			return true
	return false


func mat2str(mat = matrix) -> String:
	var string := ""
	for y in range(8):
		for x in range(8):
			var spot = mat[y][x]
			if spot:
				string += spot.mininame
			else:
				string += "*"
	for i in mat[8].keys():  # store the metadata
		var thing = mat[8][i]
		string += i + str(thing)
	return string


func drawed() -> void:
	return  # TODO: make gameovers work again
	Events.emit_signal("game_over")
	SoundFx.play("Draw")
	yield(get_tree().create_timer(5), "timeout")
	Events.emit_signal("go_back")
	SoundFx.play("Victory")


func win(winner) -> void:
	return  # TODO: make gameovers work again
	Events.emit_signal("game_over")
	print(winner, " won the game in ", Globals.turns(), " turns!")
	SoundFx.play("Victory")
	yield(get_tree().create_timer(5), "timeout")
	Events.emit_signal("go_back")
	SoundFx.play("Victory")


func check_in_check(prin = false) -> bool:  # check if in_check
	for i in range(0, 8):  # for each row
		for j in range(0, 8):  # for each column
			var spot = matrix[i][j]  # get the square
			if spot and spot.white != Globals.turn:  # enemie
				if spot.can_attack_piece(Globals.white_king if Globals.turn else Globals.black_king):  # if it can take the king
					# control never flows here
					if prin:
						Globals.in_check = true  # set in_check
						Globals.checking_piece = spot  # set checking_piece
						SoundFx.play("Check")
					print("check")
					return true  # stop at the first check found
	return false


func can_move() -> bool:
	for i in range(0, 8):  # for each row
		for j in range(0, 8):  # for each column
			var spot = matrix[i][j]  # get the square
			if spot and spot.white != Globals.team:  # enemie: checking for our enemys
				if spot.can_move():
					return true
	return false


func init_matrix() -> void:  # create the matrix
	for i in range(8):  # for each row
		matrix.append([])  # add a row
		for _j in range(8):  # for each column
			matrix[i].append(null)  # add a square
	matrix.append(default_metadata.duplicate())  # metadata for threefold repetition check
	add_pieces()  # add the pieces


func make_piece(position: Vector2, script: String, white: bool = true) -> void:  # make peace
	var piece := Piece.instance()  # create a piece
	piece.script = load(script)  # set the script
	piece.real_position = position  # set the real position
	piece.global_position = position * piece_size  # set the global position
	piece.white = white  # set its team
	pieces.add_child(piece)  # add the piece to the grid
	matrix[position.y][position.x] = piece


func init_board() -> void:  # create the board
	for i in range(8):  # for each row
		background_matrix.append([])  # add a row
		for j in range(8):  # for each column
			var square := Square.instance()  # create a square
			square.rect_size = piece_size  # set the size
			square.rect_global_position = Vector2(i, j) * piece_size  # set the position
			square.color = Globals.board_color1 if (i + j) % 2 == 0 else Globals.board_color2  # set the color
			square.real_position = Vector2(i, j)  # set the real position
			background.add_child(square)  # add the square to the background
			square.connect("clicked", self, "square_clicked")  # connect the clicked event
			background_matrix[i].append(square)  # add the square to the background matrix


func add_pieces() -> void:  # add the pieces
	add_pawns()
	add_rooks()
	add_knights()
	add_bishops()
	add_queens()
	add_kings()


func add_pawns() -> void:
	for i in range(8):
		make_piece(Vector2(i, 1), "res://pieces/Pawn.gd", false)
		make_piece(Vector2(i, 6), "res://pieces/Pawn.gd", true)


func add_rooks() -> void:
	make_piece(Vector2(0, 0), "res://pieces/Rook.gd", false)
	make_piece(Vector2(7, 0), "res://pieces/Rook.gd", false)
	make_piece(Vector2(0, 7), "res://pieces/Rook.gd", true)
	make_piece(Vector2(7, 7), "res://pieces/Rook.gd", true)


func add_knights() -> void:
	make_piece(Vector2(1, 0), "res://pieces/Knight.gd", false)
	make_piece(Vector2(6, 0), "res://pieces/Knight.gd", false)
	make_piece(Vector2(1, 7), "res://pieces/Knight.gd", true)
	make_piece(Vector2(6, 7), "res://pieces/Knight.gd", true)


func add_bishops() -> void:
	make_piece(Vector2(2, 0), "res://pieces/Bishop.gd", false)
	make_piece(Vector2(5, 0), "res://pieces/Bishop.gd", false)
	make_piece(Vector2(2, 7), "res://pieces/Bishop.gd", true)
	make_piece(Vector2(5, 7), "res://pieces/Bishop.gd", true)


func add_queens() -> void:
	make_piece(Vector2(3, 0), "res://pieces/Queen.gd", false)
	make_piece(Vector2(3, 7), "res://pieces/Queen.gd", true)


func add_kings() -> void:
	make_piece(Vector2(4, 0), "res://pieces/King.gd", false)
	make_piece(Vector2(4, 7), "res://pieces/King.gd", true)
	Globals.white_king = matrix[7][4]  # set the white king
	Globals.black_king = matrix[0][4]  # set the black king


func check_for_circle(position: Vector2) -> bool:  # check for a circle, validating movement
	return background_matrix[position.x][position.y].circle_on


func check_for_frame(position: Vector2) -> bool:  # check for a frame, validating taking
	if !is_instance_valid(matrix[position.y][position.x]):  # if there is no piece
		return false  # return false
	return matrix[position.y][position.x].frameon  # return if the frame is on


func square_clicked(position: Vector2) -> void:  # square clicked
	print(Utils.to_algebraic(position), " clicked")
	if promoting != null:
		return
	if Globals.turn != Globals.team:
		return
	var spot = matrix[position.y][position.x]  # get the spot
	if !spot or spot.white != Globals.team:
		if !is_instance_valid(last_clicked):
			return
		if check_for_frame(position):  # takeable
			handle_take(position)
		elif check_for_circle(position):  # see if theres a circle at the position
			handle_move(position)  # move
		last_clicked.clear_clicked()  # remove the circles
		last_clicked = null  # set it to null
	elif last_clicked != spot:  # we got a new piece (or pawn) clicked
		if is_instance_valid(last_clicked):  # remove the circles
			last_clicked.clear_clicked()
		last_clicked = spot  # set it to the new spot
		spot.clicked()  # tell the piece shit happeend


func handle_take(position) -> void:
	if Utils.is_pawn(last_clicked):  # if its a pawn
		var pawn = last_clicked
		if check_promote(pawn, position, "take"):
			return
	Globals.network.send_move_packet(
		PoolVector2Array([last_clicked.real_position, position]), Network.MOVEHEADERS.move
	)  # piece taking piece


func handle_move(position) -> void:
	if last_clicked is King and last_clicked.can_castle:
		for i in range(len(last_clicked.can_castle)):
			var castle_data = last_clicked.can_castle[i]
			if castle_data[0] == position:
				# send some packet
				Globals.network.send_move_packet(
					{
						"king": last_clicked.real_position,
						"rook": castle_data[1].real_position,
						"rookdestination": castle_data[2],
						"kingdestination": castle_data[0]
					},
					Network.MOVEHEADERS.castle
				)

				return
	if last_clicked is Pawn:
		var pawn = last_clicked
		if pawn.enpassant:
			for i in range(len(pawn.enpassant)):
				var en_passant_data = pawn.enpassant[i]
				if en_passant_data[0] == position:
					# send some packet
					Globals.network.send_move_packet(
						PoolVector2Array([pawn.real_position, position, en_passant_data[1].real_position]),
						Network.MOVEHEADERS.passant
					)
					return
		if check_promote(pawn, position):
			return
	Globals.network.send_move_packet(
		PoolVector2Array([last_clicked.real_position, position]), Network.MOVEHEADERS.move
	)  # piece moving


func check_promote(pawn, position, calltype: String = "move") -> bool:
	if pawn.can_promote(position):
		pawn.promote(position, calltype)
		promoting = position
		return true
	return false


func clear_fx() -> void:  # clear the circles
	for i in range(8):  # for each row
		for j in range(8):  # for each column
			var square = background_matrix[i][j]  # get the square
			square.set_circle(false)  # set the circle to false
			var piece = matrix[i][j]  # get the piece
			if piece:  # if there is a piece
				piece.set_frame(false)  # clear the frame


func _on_outoftime(who) -> void:
	if who == "white":
		win("black")
	else:
		win("white")


func _on_turn_over() -> void:
	var matstr: String = mat2str()
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
		if Globals.in_check:
			var winner := "black" if Globals.turn else "white"
			status_label.text("%s won the game by checkmate" % winner)
			win(winner)
		else:
			status_label.text("stalemate")
			drawed()
	elif threefoldrepetition():
		status_label.text("draw by threefold repetition")
		drawed()

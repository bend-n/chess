extends Piece
class_name Pawn, "res://assets/pieces/california/wP.png"

onready var whiteint = 1 if white else -1

var twostepfirstmove = false
var just_set = false
var enpassant = []


func moveto(position, real = true, take = false):
	# check if 2 step
	if real and !twostepfirstmove and !has_moved:
		if white and real_position.y - position.y == 2:
			twostepfirstmove = true
			just_set = true
		if !white and position.y - real_position.y == 2:
			twostepfirstmove = true
			just_set = true
	.moveto(position, real, take)


func _on_turn_over():
	if just_set:
		just_set = false
		return
	if twostepfirstmove:
		twostepfirstmove = false


func get_moves():
	var points = [Vector2.UP, Vector2.UP * 2]
	var moves = []
	for i in range(len(points)):
		var point = points[i]
		point *= whiteint
		point = pos_around(point)
		if at_pos(point) == null:
			if i == 1 and has_moved or at_pos(pos_around(points[0] * whiteint)) != null:
				continue
			if check_spots_check and checkcheck(point):
				continue
			if is_on_board(point):
				moves.append(point)
	moves.append_array(en_passant())
	return moves


func passant(position):
	enpassant.clear()
	moveto(position)


func get_attacks():
	var points = [Vector2.UP + Vector2.RIGHT, Vector2.UP + Vector2.LEFT]
	var moves = []
	for i in range(len(points)):
		var point = points[i]
		point *= whiteint
		point = pos_around(point)
		if !is_on_board(point):
			continue
		if check_spots_check and checkcheck(point):
			continue
		if at_pos(point) != null and at_pos(point).white != white:
			moves.append(point)
	en_passant()
	return moves


func en_passant(turncheck = true):  # in passing
	var passants = [pos_around(Vector2.LEFT), pos_around(Vector2.RIGHT)]
	var moves = []
	for i in passants:
		if !is_on_board(i):
			continue
		var spot = at_pos(i)
		if !spot:
			continue
		if spot.white == white:
			continue
		if !Utils.is_pawn(spot):
			continue
		if turncheck and white != Globals.turn:
			continue
		if !spot.twostepfirstmove:
			continue
		if check_spots_check and checkcheck(i):
			continue
		var position = i + (Vector2.UP * whiteint)
		if !at_pos(position):
			moves.append(position)
		enpassant.append([position, spot])
	return moves


func _just_before_turn_over():
	var had_a_enpassant = len(enpassant) > 0
	enpassant.clear()
	if !had_a_enpassant:  # scuffed method to check if enpassant is possible
		en_passant(false)
	var temporary = []
	for i in enpassant:
		temporary.append(i[0])
	if !temporary:
		return
	if white:
		Globals.grid.matrix[8].wcep.append_array(temporary)
	else:
		Globals.grid.matrix[8].bcep.append_array(temporary)


func _ready():
	Events.connect("turn_over", self, "_on_turn_over")
	Events.connect("just_before_turn_over", self, "_just_before_turn_over")

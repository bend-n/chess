extends Piece
class_name Pawn


func get_moves():
	var points = [Vector2.UP, Vector2.UP * 2]
	var whiteint = 1 if white else -1
	var moves = []
	for i in range(len(points)):
		var point = points[i]
		point *= whiteint
		point = pos_around(point)
		if at_pos(point) == null:
			if i == 1 and has_moved or at_pos(pos_around(points[0] * whiteint)) != null:
				continue
			if check_spots_check:
				if !checkcheck(point):
					continue
			if is_on_board(point):
				moves.append(point)
	return moves


func get_attacks():
	var points = [Vector2.UP + Vector2.RIGHT, Vector2.UP + Vector2.LEFT]
	var whiteint = int(white)
	var moves = []
	for i in range(len(points)):
		var point = points[i]
		point *= whiteint
		point = pos_around(point)
		if !is_on_board(point):
			continue
		if at_pos(point) != null and at_pos(point).white != white:
			moves.append(point)
	return moves


func _ready():
	._ready()
	shortname = "p" + team

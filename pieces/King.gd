extends Piece
class_name King, "res://assets/california/wK.png"

var castle_check = true
var can_castle = []


func get_moves():
	var moves = []
	for i in all_dirs():
		var spot = pos_around(i)
		if is_on_board(spot):
			if no_enemys and at_pos(spot):
				continue
			if check_spots_check and checkcheck(spot):
				continue
			moves.append(spot)
	if castle_check and !has_moved and !Globals.in_check:  # make sure this is only called when clicking
		moves.append_array(castleing())
	return moves


func castleing():
	var moves = []
	var rooks = [pos_around(Vector2.RIGHT * 3), pos_around(Vector2.LEFT * 4)]
	var rook_motion = [pos_around(Vector2.RIGHT), pos_around(Vector2.LEFT)]
	var king_moveto_spots = [Vector2.RIGHT, Vector2.LEFT]  # O-O  and O-O-O respectivel
	for i in range(len(rooks)):
		var rook = at_pos(rooks[i])
		if !rook is Rook:
			continue
		if rook.has_moved:
			continue
		var direction = king_moveto_spots[i]
		var posx2 = pos_around(direction * 2)
		var pos = pos_around(direction)
		if at_pos(posx2) or at_pos(pos):
			continue
		if checkcheck(posx2) or checkcheck(pos):
			continue
		can_castle.append([posx2, rook, rook_motion[i]])
		moves.append(posx2)
	return moves


func castle(position):
	can_castle.clear()
	moveto(position)


func _ready():
	._ready()
	shortname = "k" + team


func can_move():  # checks if you can legally move
	castle_check = false
	var can = can_move()
	castle_check = true
	return can


func get_attacks():
	castle_check = false
	var final = .get_attacks()
	castle_check = true
	return final

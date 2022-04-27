extends Piece
class_name King


func get_moves():
	var moves = []
	for i in all_dirs():
		var spot = pos_around(i)
		if is_on_board(spot):
			if check_spots_check and Globals.in_check and checkcheck(spot):
				continue
			moves.append(spot)
	return moves


func _ready():
	._ready()
	shortname = "k" + team

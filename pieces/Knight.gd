class_name Knight
extends Piece


func get_moves():
	var moves = [
		pos_around(Vector2(-2, -1)),
		pos_around(Vector2(-2, 1)),
		pos_around(Vector2(2, -1)),
		pos_around(Vector2(2, 1)),
		pos_around(Vector2(-1, -2)),
		pos_around(Vector2(1, -2)),
		pos_around(Vector2(-1, 2)),
		pos_around(Vector2(1, 2))
	]
	var final = []
	for i in moves:
		if is_on_board(i):
			if check_spots_check:
				if !checkcheck(i):
					continue
			final.append(i)
	return final


func _ready():
	._ready()
	shortname = "k" + team

extends Piece
class_name Knight, "res://assets/pieces/california/wN.png"


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
			if no_enemys and at_pos(i):
				continue
			if check_spots_check and checkcheck(i):
				continue
			final.append(i)
	return final

extends Piece
class_name King


func get_moves():
	var moves = [
		.pos_around(Vector2.UP),
		.pos_around(Vector2.DOWN),
		.pos_around(Vector2.LEFT),
		.pos_around(Vector2.RIGHT),
		.pos_around(Vector2(1, 1)),
		.pos_around(Vector2(1, -1)),
		.pos_around(Vector2(-1, 1)),
		.pos_around(Vector2(-1, -1))
	]
	var final = []
	for i in moves:
		if .is_on_board(i):
			final.append(i)
	return final


func _ready():
	._ready()
	shortname = "k" + team

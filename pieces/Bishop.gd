extends Piece
class_name Bishop, "res://assets/pieces/california/wB.png"


func get_moves(no_enemys = false, check_spots_check = true) -> Array:
	return traverse(all_dirs().slice(4, 8), no_enemys, check_spots_check)

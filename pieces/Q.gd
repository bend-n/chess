extends Piece
class_name Queen, "res://assets/pieces/california/wQ.png"


func get_moves(no_enemys := false, check_spots_check := true) -> PoolVector2Array:
	return traverse(all_dirs(), no_enemys, check_spots_check)

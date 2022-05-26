extends Piece
class_name Bishop, "res://assets/pieces/california/wB.png"


func get_moves(no_enemys := false, check_spots_check := true) -> PoolVector2Array:
	var dirs = PoolVector2Array(Array(all_dirs()).slice(4, 8))
	return traverse(dirs, no_enemys, check_spots_check)

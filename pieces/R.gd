extends Piece
class_name Rook, "res://assets/pieces/california/wR.png"


func get_moves(no_enemys := false, check_spots_check := true) -> PoolVector2Array:
	return traverse([Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT], no_enemys, check_spots_check)

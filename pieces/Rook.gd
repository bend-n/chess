extends Piece
class_name Rook, "res://assets/pieces/california/wR.png"


func get_moves() -> Array:
	return traverse()

extends Piece
class_name Rook, "res://assets/california/wR.png"


func get_moves():
	return .traverse()

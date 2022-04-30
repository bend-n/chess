extends Piece
class_name Bishop, "res://assets/pieces/california/wB.png"


func get_moves():
	return .traverse(.all_dirs().slice(4, 8))

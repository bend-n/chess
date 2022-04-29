extends Piece
class_name Bishop, "res://assets/california/wB.png"


func get_moves():
	return .traverse(.all_dirs().slice(4, 8))

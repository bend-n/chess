extends Piece
class_name Queen, "res://assets/pieces/california/wQ.png"


func get_moves():
	return traverse(all_dirs())

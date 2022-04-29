extends Piece
class_name Queen, "res://assets/california/wQ.png"


func get_moves():
	return traverse(all_dirs())

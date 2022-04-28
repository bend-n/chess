extends Piece
class_name Rook, "res://assets/california/wR.png"


func get_moves():
	return .traverse()


func _ready():
	._ready()
	shortname = "r" + team

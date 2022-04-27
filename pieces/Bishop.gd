extends Piece
class_name Bishop


func get_moves():
	return .traverse(.all_dirs().slice(4, 8))


func _ready():
	._ready()
	shortname = "b" + team

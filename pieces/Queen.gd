extends Piece
class_name Queen


func get_moves():
	return .traverse(.all_dirs())


func _ready():
	._ready()
	shortname = "q" + team

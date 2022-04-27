class_name Rook
extends Piece


func get_moves():
	return .traverse()


func _ready():
	._ready()
	shortname = "r" + team

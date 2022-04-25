extends Node2D
class_name Piece

var white := true
var realname = "pawn"
var sprite

onready var colorrect= $ColorRect

func move(newpos: Vector2):
	global_position = newpos

func clicked():
	colorrect.show()
	print(realname, " was clicked")

func spot(position):
	colorrect.hide()
	if position:
		print("spot ", position)

func _ready():
	colorrect.rect_size = Globals.piece_size
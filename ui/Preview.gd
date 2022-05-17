extends Node
class_name Preview

onready var squares = get_children()


func update_preview():
	for i in range(4):
		squares[i].color = Globals.board_color1 if i == 0 or i == 3 else Globals.board_color2
	squares[0].get_node("Piece").texture = load("res://assets/pieces/%s/wP.png" % Globals.piece_set)

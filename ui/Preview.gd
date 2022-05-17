extends Node
class_name Preview

onready var squares = get_children()


func update_preview(color1, color2, piece_set):
	for i in range(4):
		squares[i].color = color1 if i == 0 or i == 3 else color2
	squares[0].get_node("Piece").texture = load("res://assets/pieces/%s/wP.png" % piece_set)

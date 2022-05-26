extends BarTextureButton
class_name FlipButton, "res://assets/ui/flip_board.png"


func _pressed() -> void:
	Globals.grid.flip_board()

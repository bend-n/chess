extends Button
class_name FlipButton


func _pressed() -> void:
	Globals.grid.flip_board()

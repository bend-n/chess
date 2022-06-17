extends TextureButton

var focused = false setget set_focused


func set_focused(is_focused: bool):
	focused = is_focused
	rect_scale = Vector2(1.1, 1.1) if focused else Vector2(.9, .9)


func _ready():
	if Globals.grid:
		rect_pivot_offset = Globals.grid.piece_size / 2
		rect_min_size = Globals.grid.piece_size
	set_focused(false)

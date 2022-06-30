extends TextureButton
class_name PromotionPreview

var focused = false setget set_focused


func set_focused(is_focused: bool):
	focused = is_focused
	rect_scale = Vector2(1.1, 1.1) if focused else Vector2(.9, .9)


func _ready():
	connect("mouse_entered", self, "set_focused", [true])
	connect("mouse_exited", self, "set_focused", [false])
	stretch_mode = STRETCH_KEEP_ASPECT_CENTERED
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	expand = true
	rect_pivot_offset = Globals.grid.piece_size / 2
	rect_min_size = Globals.grid.piece_size
	set_focused(false)

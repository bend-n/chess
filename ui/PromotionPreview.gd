extends TextureButton
class_name PromotionPreview

var focused = false setget set_focused


func set_focused(is_focused: bool):
	focused = is_focused
	rect_scale = Vector2(1.1, 1.1) if focused else Vector2(.9, .9)

func size():
	rect_min_size = Globals.grid.piece_size

func _ready():
	size()
	connect("mouse_entered", self, "set_focused", [true])
	connect("mouse_exited", self, "set_focused", [false])
	stretch_mode = STRETCH_KEEP_ASPECT_CENTERED
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	expand = true
	set_focused(false)

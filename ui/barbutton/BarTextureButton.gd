extends TextureButton
class_name BarTextureButton

var focused: bool setget _focused

export(Color) var normal_color := Color.black
export(Color) var highlight_color := Color(0.670588, 0.352941, 0.352941)
export(Color) var pressed_color := Color(0.356863, 0.572549, 0.647059)
export(Color) var disabled_color := Color(0.501961, 0.501961, 0.501961)

onready var background := $Background

var n := 0


func _ready() -> void:
	_focused(false)
	n = round(rand_range(10, 20))


func set_disabled(new: bool) -> void:
	disabled = new
	self_modulate = Color.gray if disabled else Color.white
	mouse_default_cursor_shape = CURSOR_FORBIDDEN if disabled else CURSOR_POINTING_HAND


func _process(_delta):
	if visible and Engine.get_idle_frames() % n == 0:
		_update()


func _update():
	if disabled:
		background.color = disabled_color
	elif pressed:
		background.color = pressed_color
	elif focused:
		background.color = highlight_color
	else:
		background.color = normal_color


func _focused(q: bool):
	focused = q

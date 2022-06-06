extends TextureButton
class_name BarTextureButton

var focused: bool

export(Color) var normal_color := Color.black
export(Color) var highlight_color := Color(0.670588, 0.352941, 0.352941)
export(Color) var pressed_color := Color(0.356863, 0.572549, 0.647059)
export(Color) var disabled_color := Color(0.501961, 0.501961, 0.501961)

onready var background := $Background


func _ready() -> void:
	_focused(false)


func set_disabled(new: bool) -> void:
	disabled = new
	self_modulate = Color(.1, .1, .1, 0.5) if disabled else Color.white


func _input(_event:InputEvent):
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

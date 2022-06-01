extends TextureButton

export(Color) var focusedcolor := Color(0.396078, 0.423529, 0.45098)
export(Texture) var map_tex

onready var pw := $"../Password"


func _ready() -> void:
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(map_tex.get_data())
	texture_click_mask = bitmap


func _focus(what: bool) -> void:
	modulate = focusedcolor if what else Color.white


func _toggled(button_pressed: bool) -> void:
	pw.secret = button_pressed

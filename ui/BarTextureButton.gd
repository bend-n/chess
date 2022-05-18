extends Control
class_name BarTextureButton

signal pressed()

var focused = false

export(Texture) var texture

export(Color) var normal_color
export(Color) var highlight_color
export(Color) var pressed_color

onready var texture_button = $Texture
onready var background = $Background

func _ready():
	texture_button.texture_normal = texture
	texture_button.texture_focused = texture
	texture_button.texture_pressed = texture
	texture_button.texture_hover = texture

func _on_Texture_pressed():
	emit_signal("pressed")

func _process(_delta):
	if texture_button.pressed:
		background.color = pressed_color
	elif focused:
		background.color = highlight_color
	else:
		background.color = normal_color

func _on_Texture_mouse_entered():
	focused = true
	background.color = highlight_color


func _on_Texture_mouse_exited():
	focused = false
	background.color = normal_color


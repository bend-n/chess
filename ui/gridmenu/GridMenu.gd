extends GridContainer
class_name GridMenu

const texture_button = preload("res://ui/barbutton/BarTextureButton.tscn")
signal pressed(index)


func open():
	columns = round(sqrt(get_child_count()))
	show()


func add_icon_item(icon: Texture, tooltip: String, size: Vector2) -> BarTextureButton:
	var tex: BarTextureButton = texture_button.instance()
	tex.connect("pressed", self, "_pressed", [get_child_count()])
	tex.expand = true
	tex.texture_normal = icon
	tex.name = tooltip
	tex.rect_min_size = size
	tex.hint_tooltip = tooltip
	tex.stretch_mode = tex.STRETCH_KEEP_ASPECT_CENTERED
	add_child(tex)
	return tex


func add_text_item(text: String, tooltip: String, size: Vector2) -> Button:
	var b := Button.new()
	b.hint_tooltip = tooltip
	b.name = tooltip
	b.rect_min_size = size
	b.text = text
	b.connect("pressed", self, "_pressed", [get_child_count()])
	add_child(b)
	return b


func _pressed(index: int):
	emit_signal("pressed", index)

extends GridContainer
class_name GridMenu

const texture_button = preload("res://ui/barbutton/BarTextureButton.tscn")
signal pressed(index)

func open():
	columns = round(sqrt(get_child_count()))
	show()

func add_item(icon : Texture, tooltip : String, size:Vector2)->void:
	var pnl := PanelContainer.new()
	var tex := texture_button.instance()
	tex.connect("pressed", self, "_pressed", [get_child_count()])
	tex.expand = true
	tex.texture_normal = icon
	tex.name = str(get_child_count()+1)
	tex.rect_min_size = size
	tex.hint_tooltip = tooltip
	tex.stretch_mode = tex.STRETCH_KEEP_ASPECT_CENTERED
	tex.set_anchors_preset(PRESET_WIDE)
	var back :ColorRect = tex.get_node("Background")
	back.margin_left = -5
	back.margin_right = 5
	back.margin_top = -5
	back.margin_bottom = 5
	pnl.add_child(tex)
	add_child(pnl)

func _pressed(index:int):
	get_children()[index].get_children()[0]._focused(false)
	emit_signal("pressed", index)

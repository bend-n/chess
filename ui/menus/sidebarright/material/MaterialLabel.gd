extends HBoxContainer
class_name MaterialLabel

var l := Label.new()


func _ready():
	add_constant_override("separation", 0)
	add_child(l)
	l.add_font_override("font", load("res://ui/ubuntu-bold-small.tres"))
	l.name = "Label"


# {p=0, ...}
func display(pieces: Dictionary, score: int) -> void:
	get_tree().call_group("material@" + name, "free")
	for p in pieces:
		for i in pieces[p]:
			var t := TextureRect.new()
			t.expand = true
			t.stretch_mode = t.STRETCH_KEEP_ASPECT
			t.rect_min_size = Vector2(30, 30)
			t.texture = load("res://assets/silhouette/%s.png" % p.to_upper())

			add_child(t)
			t.add_to_group("material@" + name)
			t.name = p
	move_child(l, get_child_count())
	l.text = ("+%d " % score) if score > 0 else ""

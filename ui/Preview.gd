tool
extends GridContainer
class_name Preview

var size = Vector2(5, 4)

const pieces = [
	"R", "N", "B", "Q", "K",
	"P", "P", "P", "P", "P",
	"P", "P", "P", "P", "P", 
	"K", "Q", "B", "N", "R", 
]

func _init():
	columns = size.x
	for x in size.x:
		for y in size.y:
			var clr = ColorRect.new()
			clr.name = "%s%s" % [x, y]
			clr.rect_min_size = Vector2(100, 100)
			var tex = TextureRect.new()
			tex.rect_min_size = Vector2(100, 100)
			tex.expand = true
			tex.name = "Piece"
			clr.add_child(tex)
			add_child(clr)
	if Engine.is_editor_hint():
		update_preview(Color(0.870588, 0.890196, 0.901961), Color(0.54902, 0.635294, 0.678431), "california")


func update_preview(color1, color2, piece_set):
	var squares = get_children()
	for i in range(size.x * size.y):
		squares[i].color = color1 if i % 2 == 0 else color2
	var top = (size.x * size.y) / 2
	for i in size.x * size.y:
		var node = squares[i].get_node("Piece")
		var things = [piece_set, "b" if i < top else "w", pieces[i]]
		node.texture = load("res://assets/pieces/%s/%s%s.png" % things)

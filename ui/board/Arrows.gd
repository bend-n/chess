extends Control

var arrows := []
var first: Vector2
var ev: Vector2
var b: Grid

const w = 20


func _setup(_b: Grid):
	b = _b
	Events.connect("turn_over", self, "on_turn_over")
	for k in Chess.SQUARE_MAP:
		b.background_array[Chess.SQUARE_MAP[k]].connect("right_clicked", self, "right_clicked", [k])


func right_clicked(clicked: String) -> void:
	first = ((Chess.algebraic2vec(clicked) * b.piece_size) + b.piece_size / 2)


func _process(_delta):
	update()


func _draw():
	if !b:
		return
	var s = b.piece_size
	var c = b.overlay_color
	if first:
		var loc_m = ((get_local_mouse_position() / s) - Vector2(.5, .5)).round()
		loc_m = Vector2(clamp(loc_m.x, 0, 7), clamp(loc_m.y, 0, 7))
		var m_pos = (loc_m * s) + s / 2
		if Input.is_action_pressed("rclick"):  # dragging
			draw_line(first, m_pos, c, w, true)
			draw_triangle(first.angle_to_point(m_pos), m_pos, c)
		else:
			if first != m_pos:
				var arr: PoolVector2Array = [first, m_pos]
				if arrows.find(arr) == -1:
					arrows.append(arr)
				else:
					arrows.erase(arr)  # redoing == kill
			first = Vector2.ZERO

	for arrow in arrows:
		draw_line(arrow[0], arrow[1], c, w, true)
		draw_triangle(arrow[0].angle_to_point(arrow[1]), arrow[1], c)


# r: the radians of rotation.
func draw_triangle(r: float, p: Vector2, c: Color) -> void:
	var tri: PoolVector2Array = [Vector2(-24, 0), Vector2(0, -40), Vector2(24, 0)]
	for i in range(len(tri)):
		tri[i] = tri[i].rotated(r - PI / 2) + p
	draw_colored_polygon(tri, c)


func clear_arrows():
	arrows.resize(0)
	first = Vector2.ZERO


func on_turn_over():
	if b.chess.turn != Globals.team:  # i just went; arrows can go away now
		clear_arrows()

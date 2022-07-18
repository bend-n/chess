extends Control

var arrows := []  # [from, to, color]
var circles := []  # [position, color]
var first: Vector2
var b: Grid

var t := 0.0

const w := 15

export(Color) var red_overlay
export(Color) var green_overlay


func _setup(_b: Grid):
	b = _b
	for k in Chess.SQUARE_MAP:
		b.background_array[Chess.SQUARE_MAP[k]].connect("right_clicked", self, "right_clicked", [k])
		b.background_array[Chess.SQUARE_MAP[k]].connect("clicked", self, "left_clicked", [k])


func right_clicked(clicked: String) -> void:
	t = 0
	first = ((Chess.algebraic2vec(clicked) * b.piece_size) + b.piece_size / 2)


func left_clicked(sq: String) -> void:
	if !b.get_piece(sq):
		clear_arrows()


func _process(delta):
	t += delta
	update()


func _draw():
	if !b:
		return
	var s = b.piece_size
	if first:
		var shift = Input.is_action_pressed("shift")
		var loc_m = ((b.get_local_mouse_position() / s) - Vector2(.5, .5)).round()
		loc_m = Vector2(clamp(loc_m.x, 0, 7), clamp(loc_m.y, 0, 7))
		var m_pos = ((loc_m * s) + s / 2).move_toward(first, 25)
		var clr = red_overlay if shift else green_overlay
		if Input.is_action_pressed("rclick"):  # previews
			if first != m_pos:
				draw_arrow(first, m_pos, clr)
			elif t <= .25:
				draw_arc(first, (s.x / 2) - 6, 0, PI * 2, 40, clr, 10, true)
		else:
			var flag := true  # no for-else :c
			if first != m_pos:
				var arr := [first, m_pos, clr]
				for i in range(len(arrows)):
					if arrows[i][0] == first and arrows[i][1] == m_pos:
						arrows.remove(i)
						flag = false
						break
				if flag:
					arrows.append(arr)
			elif t <= .25:
				var arr := [first, clr]
				for i in range(len(circles)):
					if circles[i][0] == arr[0]:
						circles.remove(i)
						flag = false
						break
				if flag:
					circles.append(arr)
			first = Vector2.ZERO
			t = 0

	for a in arrows:
		draw_arrow(a[0], a[1], a[2])
	for ci in circles:
		draw_arc(ci[0], (s.x / 2) - 6, 0, PI * 2, 40, ci[1], 10, true)


func draw_arrow(start: Vector2, end: Vector2, clr: Color):
	draw_circle(start, float(w) / 2, clr)
	draw_line(start, end, clr, w, true)
	draw_triangle(start.angle_to_point(end), end, clr)


# r: the radians of rotation.
func draw_triangle(r: float, p: Vector2, c: Color) -> void:
	var tri: PoolVector2Array = [Vector2(-24, 0), Vector2(0, -40), Vector2(24, 0)]
	for i in range(len(tri)):
		tri[i] = tri[i].rotated(r - PI / 2) + p
	draw_primitive(tri, [c, c, c], [])


func clear_arrows():
	arrows.resize(0)
	circles.resize(0)
	first = Vector2.ZERO

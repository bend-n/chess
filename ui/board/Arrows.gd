extends Control

const INVALID := Vector2(-1, -1)

var arrows := []
var circles := []
var arrow_origin: Vector2 = INVALID
var b: Grid

var t := 0.0

const w := 15

export(Color) var red_overlay
export(Color) var green_overlay

const arrow_default_offset := .5
const arrow_incrementing_offset := .1
const arrow_max_incrementing_offset := .3


func _setup(_b: Grid):
	b = _b
	for k in Chess.SQUARE_MAP:
		b.background_array[Chess.SQUARE_MAP[k]].connect("right_clicked", self, "right_clicked", [k])
		b.background_array[Chess.SQUARE_MAP[k]].connect("clicked", self, "left_clicked", [k])


func right_clicked(clicked: String) -> void:
	arrow_origin = Chess.algebraic2vec(clicked)
	t = 0


func left_clicked(sq: String) -> void:
	if !b.get_piece(sq):
		clear_arrows()


func _process(delta):
	t += delta
	update()


func scale_vector(v: Vector2) -> Vector2:
	return (v * b.piece_size) + b.piece_size / 2


func descale_vector(v: Vector2) -> Vector2:
	return ((v / b.piece_size) - Vector2(.5, .5)).round()


func shorten(v: Vector2, origin: Vector2, by: float) -> Vector2:
	return (v).move_toward(origin, by)


func shorten_arrows_at(v: Vector2) -> void:
	var shortenable := []
	for arrow in arrows:
		if arrow.coord_dest == v:
			shortenable.append(arrow)
	var shorten := (
		arrow_default_offset
		+ min((len(shortenable) - 1) * arrow_incrementing_offset, arrow_max_incrementing_offset)
	)
	for arrow in shortenable:
		arrow.dest = shorten(arrow.coord_dest, arrow.origin, shorten)


func build_arrow(from: Vector2, to: Vector2, color: Color) -> Dictionary:
	return {origin = from, dest = to, coord_dest = to, color = color}


func _draw():
	if !b:
		return
	if arrow_origin != INVALID:
		var shift := Input.is_action_pressed("shift")
		var mouse_position := descale_vector(b.get_local_mouse_position())
		mouse_position = Vector2(clamp(mouse_position.x, 0, 7), clamp(mouse_position.y, 0, 7))
		var clr: Color = red_overlay if shift else green_overlay
		if Input.is_action_pressed("rclick"):  # previews
			if arrow_origin != mouse_position:
				draw_arrow(arrow_origin, shorten(mouse_position, arrow_origin, arrow_default_offset), clr)
			elif t <= .25:
				draw_ring(arrow_origin, clr)
		else:
			var flag := true  # no for-else :c
			if arrow_origin != mouse_position:
				for i in range(len(arrows)):
					if arrows[i].origin == arrow_origin and arrows[i].coord_dest == mouse_position:
						arrows.remove(i)
						flag = false
						break
				if flag:
					arrows.append(build_arrow(arrow_origin, mouse_position, clr))
					shorten_arrows_at(mouse_position)
			elif t <= .25:
				for i in range(len(circles)):
					if circles[i].origin == arrow_origin:
						circles.remove(i)
						flag = false
						break
				if flag:
					circles.append({origin = arrow_origin, color = clr})
			arrow_origin = INVALID
			t = 0

	for a in arrows:
		draw_arrow(a.origin, a.dest, a.color)
	for ci in circles:
		draw_ring(ci.origin, ci.color)


func draw_arrow(start: Vector2, end: Vector2, clr: Color):
	start = scale_vector(start)
	end = scale_vector(end)
	draw_circle(start, float(w) / 2, clr)
	draw_line(start, end, clr, w, true)
	draw_triangle(start.angle_to_point(end), end, clr)


# r: the radians of rotation.
func draw_triangle(r: float, p: Vector2, c: Color) -> void:
	var tri: PoolVector2Array = [Vector2(-24, 0), Vector2(0, -40), Vector2(24, 0)]
	for i in range(len(tri)):
		tri[i] = tri[i].rotated(r - PI / 2) + p
	draw_primitive(tri, [c, c, c], [])


func draw_ring(at: Vector2, clr: Color) -> void:
	at = scale_vector(at)
	draw_arc(at, (b.piece_size.x / 2) - 6, 0, PI * 2, 40, clr, 10, true)


func clear_arrows():
	arrows.resize(0)
	circles.resize(0)
	arrow_origin = INVALID

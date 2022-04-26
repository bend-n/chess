extends Node2D
class_name Piece, "res://assets/california/wP.png"

var real_position = Vector2.ZERO
var white := true
var realname = "pawn"
var has_moved = false
var sprite

var black_holder

onready var tween = $Tween
onready var colorrect = $ColorRect
onready var frame = $Frame


func _ready():
	frame.position = Globals.grid.piece_size / 2
	frame.modulate = Globals.grid.overlay_color
	colorrect.color = Globals.grid.overlay_color
	colorrect.rect_size = Globals.grid.piece_size


func clicked():
	colorrect.show()
	create_circles()
	print(realname, " was clicked")


func clear_clicked():  # TODO: fix this shit
	colorrect.hide()
	Globals.grid.clear_circles()
	Globals.grid.clear_frames()


func move(newpos: Vector2):  # dont use directly; use moveto
	has_moved = true
	tween.interpolate_property(
		self,
		"global_position",
		global_position,
		newpos * Globals.grid.piece_size,
		0.5,
		Tween.TRANS_BACK,
		Tween.EASE_IN_OUT
	)
	tween.start()
	# global_position = newpos * Globals.grid.piece_size


func moveto(position):
	Globals.grid.matrix[real_position.y][real_position.x] = null
	Globals.grid.matrix[position.y][position.x] = self
	real_position = position
	move(position)
	Globals.turn = not Globals.turn
	Globals.turns += 1


func pos_around(around_vector):
	return real_position + around_vector


func all_dirs():
	return [
		Vector2.UP,
		Vector2.DOWN,
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2(1, 1),
		Vector2(1, -1),
		Vector2(-1, 1),
		Vector2(-1, -1)
	]


func create_circles():
	# for motion
	match realname:
		"pawn":
			var carry = (
				[pos_around(Vector2.UP)]
				if has_moved
				else [pos_around(Vector2.UP), pos_around(Vector2.UP * 2)]
			)
			if !white:
				carry = (
					[pos_around(Vector2.DOWN)]
					if has_moved
					else [pos_around(Vector2.DOWN), pos_around(Vector2.DOWN * 2)]
				)
			set_circle(carry)
			# deal with the take logic
			carry = []
			var takes = [pos_around(Vector2(-1, -1)), pos_around(Vector2(1, -1))]
			if !white:
				takes = [pos_around(Vector2(-1, 1)), pos_around(Vector2(1, 1))]
			for i in takes:
				i = clamp_vector(i)
				if i == null:
					continue
				carry.append(i)
			set_circle(carry, "take")
		"king":
			var carry = [
				pos_around(Vector2.UP),
				pos_around(Vector2.DOWN),
				pos_around(Vector2.LEFT),
				pos_around(Vector2.RIGHT),
				pos_around(Vector2(1, 1)),
				pos_around(Vector2(1, -1)),
				pos_around(Vector2(-1, 1)),
				pos_around(Vector2(-1, -1))
			]
			set_circle(carry)
			set_circle(carry, "take")  # king ez
		"knight":
			var carry = [
				pos_around(Vector2(-2, -1)),
				pos_around(Vector2(-2, 1)),
				pos_around(Vector2(2, -1)),
				pos_around(Vector2(2, 1)),
				pos_around(Vector2(-1, -2)),
				pos_around(Vector2(1, -2)),
				pos_around(Vector2(-1, 2)),
				pos_around(Vector2(1, 2))
			]
			set_circle(carry)
			set_circle(carry, "take")
		"rook":
			var carry = traverse(all_dirs().slice(0, 4))
			set_circle(carry)
			set_circle(carry, "take")
		"bishop":
			var carry = traverse(all_dirs().slice(4, 8))
			set_circle(carry)
			set_circle(carry, "take")
		"queen":
			var carry = traverse(all_dirs())
			set_circle(carry)
			set_circle(carry, "take")


func traverse(arr = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]):
	var carry = []
	for i in arr:
		black_holder = false
		var pos = real_position
		while true:
			pos = pos + i
			pos = clamp_vector(pos)
			if !traverse_helper(pos):
				break
			carry.append(pos)
	black_holder = false
	return carry


func traverse_helper(pos):
	if pos == null:
		return null
	pos = at_pos(pos)
	if pos:
		if pos.white != Globals.turn and !black_holder:
			black_holder = true
			return true
		return null
	return true


func at_pos(vector):
	return Globals.grid.matrix[vector.y][vector.x]


func set_circle(positions: Array, type := "move"):
	for i in range(len(positions)):
		var pos = clamp_vector(positions[i])
		if pos == null:
			continue
		var spot = at_pos(pos)
		if type == "move":
			if spot:
				continue
			Globals.grid.background_matrix[pos.x][pos.y].set_circle(true)
		elif type == "take":
			if spot and spot.white != Globals.turn:
				spot.set_frame(true)


func set_frame(boolean):
	frame.visible = boolean


func clamp_vector(vector: Vector2):
	if vector.y < 0 or vector.y > 7 or vector.x < 0 or vector.x > 7:
		return null
	vector.x = clamp(vector.x, 0, 7)
	vector.y = clamp(vector.y, 0, 7)
	return vector


func take(piece: Piece):
	var piecepos = piece.real_position
	piece.queue_free()
	moveto(piecepos)

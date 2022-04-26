extends Node2D
class_name Piece, "res://assets/california/wP.png"

var real_position = Vector2.ZERO
var white := true
var realname = "pawn"
var shortname = ""
var has_moved = false
var sprite
var frameon

onready var tween = $Tween
onready var colorrect = $ColorRect
onready var frame = $Frame


func _ready():
	frame.position = Globals.grid.piece_size / 2
	frame.modulate = Globals.grid.overlay_color
	colorrect.color = Globals.grid.overlay_color
	colorrect.rect_size = Globals.grid.piece_size
	var wh = "w" if white else "b"
	shortname = short_name().to_lower() + wh.to_upper()


func short_name():
	match realname:
		"pawn":
			return "P"
		"rook":
			return "R"
		"knight":
			return "N"
		"bishop":
			return "B"
		"queen":
			return "Q"
		"king":
			return "K"


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


func moveto(position, real = true):
	Globals.grid.matrix[real_position.y][real_position.x] = null
	Globals.grid.matrix[position.y][position.x] = self
	if real:
		real_position = position
		move(position)
		Globals.turn = not Globals.turn
		Globals.turns += 1
		Events.emit_signal("turn_over")


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


func reality(carry, real):
	if real:
		set_circle(carry)
		set_circle(carry, "take")
	else:
		var result = set_circle(carry, "take", false)
		return result  # checking if king is takeable


func create_circles(real = true):
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
			if real:
				set_circle(carry)
			# deal with the take logic
			carry = []
			var takes = [pos_around(Vector2(-1, -1)), pos_around(Vector2(1, -1))]
			if !white:
				takes = [pos_around(Vector2(-1, 1)), pos_around(Vector2(1, 1))]
			for i in takes:
				if not is_on_board(i):
					continue
				carry.append(i)
			if real:
				set_circle(carry, "take")
			else:
				return set_circle(carry, "take", false)
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
			return reality(carry, real)
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
			return reality(carry, real)
		"rook":
			var carry = traverse(all_dirs().slice(0, 4))
			return reality(carry, real)
		"bishop":
			var carry = traverse(all_dirs().slice(4, 8))
			return reality(carry, real)
		"queen":
			# debug with queen
			print("queen here!")
			print("my real position is")
			print(real_position)
			var carry = traverse(all_dirs())
			var check_king = reality(carry, real)
			print("yes" if check_king else "no")
			return check_king


func traverse(arr = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]):
	var carry = []
	for i in arr:
		var pos = real_position
		while true:
			pos = pos + i
			if not is_on_board(pos):
				break
			if at_pos(pos) != null:
				carry.append(pos)
				break
			carry.append(pos)
	return carry


func at_pos(vector):
	return Globals.grid.matrix[vector.y][vector.x]


func set_circle(positions: Array, type := "move", real = true):
	for i in range(len(positions)):
		var pos = positions[i]
		if not is_on_board(pos):
			continue
		var spot = at_pos(pos)
		if type == "move":
			if spot:
				continue
			if checkcheck(pos):
				Globals.grid.background_matrix[pos.x][pos.y].set_circle(true)
		elif type == "take":
			var team = Globals.turn if real else !Globals.turn
			if spot and spot.white != team:
				if Globals.in_check and spot != Globals.checking_piece:
					return
				spot.set_frame(true)
				if spot.realname == "king":
					if real:
						printerr("shit")
					else:
						return true
	return false


func checkcheck(pos):
	if Globals.in_check:
		var mat = Globals.grid.matrix.duplicate(true)
		moveto(pos, false)
		print("moved " + realname + " to " + str(pos))
		var retu = true
		if !Globals.grid.check_in_check(false):
			print("did not fix check")
			retu = false
		Globals.grid.print_matrix_pretty(mat)
		Globals.grid.matrix = mat
		return retu
	return true


func pd(string, toprint):
	if toprint:
		print(string)


func is_on_board(vector: Vector2):  #-> bool: my syntax highlight doesnt like return annotation
	if vector.y < 0 or vector.y > 7 or vector.x < 0 or vector.x > 7:
		return false
	return true


func take(piece: Piece):
	var piecepos = piece.real_position
	piece.queue_free()
	moveto(piecepos)


func set_frame(value, real = true):
	frameon = value
	if real:
		frame.visible = value

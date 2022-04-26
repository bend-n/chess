extends Node2D
class_name Piece, "res://assets/california/wP.png"

var real_position = Vector2.ZERO
var white := true
var realname = "pawn"
var has_moved = false
var sprite
var frameon = false
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
				i = check_bounds(i)
				if !i:
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
			var carry = traverse(all_dirs())
			return reality(carry, real)


func traverse(arr = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]):
	var carry = []
	for i in arr:
		var pos = real_position
		while true:
			pos = pos + i
			pos = check_bounds(pos)
			if blocking(pos):
				break
			carry.append(pos)
	pd(carry, realname == "queen")
	return carry


func blocking(pos):
	if black_holder:
		black_holder = false
		return true
	if pos == null: # its null
		return true
	var piece = at_pos(pos) # get the piece at pos
	if piece: # it isnt null
		if piece.white != Globals.turn and !black_holder: # other team
			black_holder = true # store a variable so we can have one black thing
			return false
		return true
	return false # it is null


func at_pos(vector):
	return Globals.grid.matrix[vector.y][vector.x]


func set_circle(positions: Array, type := "move", real = true):
	for i in range(len(positions)):
		var pos = check_bounds(positions[i])
		if !pos:
			continue
		var spot = at_pos(pos)
		if type == "move":
			if spot:
				continue
			Globals.grid.background_matrix[pos.x][pos.y].set_circle(true)
		elif type == "take":
			var team = Globals.turn if real else !Globals.turn
			if spot and spot.white != team:
				spot.set_frame(true)
				if spot.realname == "king":
					if real:
						printerr("shit")
					else:
						print("chec")
						return true
	return false


func pd(string, toprint):
	if toprint:
		print(string)


func set_frame(boolean, real = true):
	frameon = boolean
	if real:
		frame.visible = boolean


func check_bounds(vector: Vector2):
	if vector.y < 0 or vector.y > 7 or vector.x < 0 or vector.x > 7:
		return null
	return vector


func take(piece: Piece):
	var piecepos = piece.real_position
	piece.queue_free()
	moveto(piecepos)

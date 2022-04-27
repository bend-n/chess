extends Node2D
class_name Piece, "res://assets/california/wP.png"

var real_position = Vector2.ZERO
var white := true
var shortname = ""
var has_moved = false
var sprite
var frameon
var team = "w"
var check_spots_check = true

onready var tween = $Tween
onready var anim = $AnimationPlayer
onready var colorrect = $ColorRect
onready var frame = $Frame


func _ready():
	team = "W" if white else "B"
	frame.position = Globals.grid.piece_size / 2
	frame.modulate = Globals.grid.overlay_color
	colorrect.color = Globals.grid.overlay_color
	colorrect.rect_size = Globals.grid.piece_size


func clicked():
	colorrect.show()
	set_circle(get_moves())
	set_circle(get_attacks(), "take")
	print(shortname, " was clicked")


func clear_clicked():
	colorrect.hide()
	Globals.grid.clear_fx()


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
	anim.play("Move")
	tween.start()
	# global_position = newpos * Globals.grid.piece_size


func moveto(position, real = true):
	Globals.grid.matrix[real_position.y][real_position.x] = null
	Globals.grid.matrix[position.y][position.x] = self
	if real:
		real_position = position
		move(position)


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


func traverse(arr = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]):
	var circle_array = []
	for i in arr:
		var pos = real_position
		while true:
			pos += i
			if !is_on_board(pos):
				break

			if at_pos(pos) != null:  # only one black
				if check_spots_check:
					if checkcheck(pos):
						circle_array.append(pos)
						break
					break
				break
			if check_spots_check:
				if !checkcheck(pos):
					continue
			circle_array.append(pos)
	return circle_array


func at_pos(vector):
	return Globals.grid.matrix[vector.y][vector.x]


func get_moves():  # @Override
	pass


func get_attacks():  # @Override
	var moves = get_moves()  # assumes the attacks are same as moves
	var final = []
	for i in moves:
		if at_pos(i) != null and at_pos(i).white != white:
			final.append(i)
	return final


func can_check_king(king):
	check_spots_check = false
	for attackable in get_attacks():
		if at_pos(attackable) == king:
			check_spots_check = true
			return true
	check_spots_check = true
	return false


func create_move_circles(pos):
	Globals.grid.background_matrix[pos.x][pos.y].set_circle(true)  # make the move circle


func create_take_circles(spot):  # create take circles
	spot.set_frame(true)  # turn on the little take frame on the piece, to show its takeable


func set_circle(positions: Array, type := "move"):
	for pos in positions:
		var spot = at_pos(pos)  # get the piece at the position
		if type == "move":  # if the type is move
			create_move_circles(pos)  # create the move circle
		elif type == "take":  # if the type is take
			create_take_circles(spot)  # if the king is in check, return true


func checkcheck(pos):  # moves to position, then checks if your king is in check
	if Globals.in_check:  # if you are in check
		var mat = Globals.grid.matrix.duplicate(true)  # make a copy of the matrix
		moveto(pos, false)  # move to the position
		print("moved " + shortname + " to " + str(pos))
		var retu = true  # return true by default
		if !Globals.grid.check_in_check():  # if you are still in check
			print("did not fix check")  # sadge
			retu = false  # return false, but fix the matrix first
		# Globals.grid.print_matrix_pretty(mat)  # print the matrix
		Globals.grid.matrix = mat  # revert changes on the matrix
		return retu
	return true


func is_on_board(vector: Vector2):
	if vector.y < 0 or vector.y > 7 or vector.x < 0 or vector.x > 7:
		return false
	return true


func take(piece: Piece):
	clear_clicked()
	piece.took()
	moveto(piece.real_position)


func took():  # called when piece is taken
	anim.play("Take")


func set_frame(value):
	frameon = value
	frame.visible = value

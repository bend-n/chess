extends Node2D
class_name Piece, "res://assets/pieces/california/wP.png"

var real_position := Vector2.ZERO
var white := true
var shortname := ""
var mininame := "♙"
var has_moved := false
var frameon := false
var team := "w"
var check_spots_check := true
var no_enemys := false

onready var sprite := $Sprite
onready var tween := $Tween
onready var anim := $AnimationPlayer
onready var colorrect := $ColorRect
onready var frame := $Frame


func _ready() -> void:
	team = "w" if white else "b"
	sprite.position = Globals.grid.piece_size / 2
	var tmp: Array = Utils.get_node_name(self)
	mininame = tmp[0]
	shortname = tmp[1]
	frame.position = Globals.grid.piece_size / 2
	frame.modulate = Globals.grid.overlay_color
	colorrect.color = Globals.grid.overlay_color
	colorrect.rect_size = Globals.grid.piece_size
	load_texture()


func load_texture(path := "%s%s%s.png" % [Globals.grid.ASSETS_PATH, team, shortname.to_upper()]) -> void:
	sprite.texture = load(path)


func clicked() -> void:
	colorrect.show()
	set_circle(get_moves())
	set_circle(get_attacks(), "take")


func clear_clicked() -> void:
	colorrect.hide()
	Globals.grid.clear_fx()


func algebraic_take_notation(position, startpos = real_position) -> String:
	var starter := shortname if shortname != "p" else to_algebraic(startpos)[0]
	return starter + "x" + to_algebraic(position)


func algebraic_move_notation(position) -> String:
	var starter := shortname if shortname != "p" else ""
	return starter + to_algebraic(position)


static func to_algebraic(position) -> String:
	return Globals.grid.background_matrix[position.x][position.y].get_string()


func move(newpos: Vector2) -> void:  # dont use directly; use moveto
	tween.interpolate_property(
		self, "global_position", global_position, newpos * Globals.grid.piece_size, 0.3, Tween.TRANS_BACK
	)
	anim.play("Move")
	tween.start()


func moveto(position, real := true, take := false, override_moveto = false) -> void:
	Globals.grid.matrix[real_position.y][real_position.x] = null
	Globals.grid.matrix[position.y][position.x] = self
	if real:
		if !override_moveto:
			if !take:
				Utils.add_move(algebraic_move_notation(position))
			else:
				Utils.add_move(algebraic_take_notation(position))
		real_position = position
		move(real_position)
		print("%s moving from %s to %s" % [mininame + shortname + " white" if white else " black", Utils.to_algebraic(global_position / Globals.grid.piece_size), Utils.to_algebraic(real_position)])
		SoundFx.play("Move")
		has_moved = true


func pos_around(around_vector) -> Vector2:
	return real_position + around_vector


static func all_dirs() -> Array:
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


func traverse(arr := [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]) -> Array:
	var circle_array := []
	for i in arr:
		var pos := real_position
		while true:
			pos += i
			if !is_on_board(pos):
				break
			if at_pos(pos) != null:  # only one enemy
				if no_enemys:  # or none
					break
				circle_array.append(pos)
				break
			if check_spots_check and checkcheck(pos):
				continue
			circle_array.append(pos)
	return circle_array


static func at_pos(vector: Vector2):
	if is_instance_valid(Globals.grid):
		return Globals.grid.matrix[vector.y][vector.x]
	return null


func can_move() -> bool:  # checks if you can legally move
	if get_moves().size() != 0 or get_attacks().size() != 0:
		return true
	return false


func get_moves() -> Array:  # @Override
	return []


func get_attacks() -> Array:  # @Override
	no_enemys = false
	var moves: Array = get_moves()  # assumes the attacks are same as moves
	var final := []
	for i in moves:
		if at_pos(i) != null:
			if at_pos(i).white != white:  # attack ze enemie
				if check_spots_check and checkcheck(i):
					continue
				final.append(i)
	no_enemys = true
	return final


func can_attack_piece(piece) -> bool:
	check_spots_check = false
	for pos in get_attacks():
		if at_pos(pos) == piece:
			check_spots_check = true
			return true
	check_spots_check = true
	return false


static func create_move_circles(pos) -> void:
	Globals.grid.background_matrix[pos.x][pos.y].set_circle(true)  # make the move circle


static func create_take_circles(spot) -> void:  # create take circles
	spot.set_frame()  # turn on the little take frame on the piece, to show its takeable


static func set_circle(positions: Array, type := "move") -> void:
	for pos in positions:
		var spot = at_pos(pos)  # get the piece at the position
		if type == "move":
			create_move_circles(pos)  # create the move circle
		elif type == "take":
			create_take_circles(spot)  # if the king is in check, return true


func checkcheck(pos) -> bool:  # moves to position, then checks if your king is in check
	# TODO: figure out why this function isnt working with can_move()
	var mat: Array = Globals.grid.matrix.duplicate(true)  # make a copy of the matrix
	moveto(pos, false)  # move to the position
	if Globals.grid.check_in_check():  # if you are still in check
		Globals.grid.matrix = mat  # revert changes on the matrix
		return true
	Globals.grid.matrix = mat
	return false


static func is_on_board(vector: Vector2) -> bool:  # limit the vector to the board
	if vector.y < 0 or vector.y > 7 or vector.x < 0 or vector.x > 7:
		return false
	return true


func take(piece: Piece) -> void:
	clear_clicked()
	piece.took()
	moveto(piece.real_position, true, true)
	Globals.reset_halfmove()


func took() -> void:  # called when piece is taken
	SoundFx.play("Capture")
	Globals.grid.matrix[real_position.y][real_position.x] = null
	anim.play("Take")


func set_frame(value = true) -> void:
	frameon = value
	frame.visible = value

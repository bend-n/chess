extends Control
class_name Piece, "res://assets/pieces/california/wP.png"

var real_position := Vector2.ZERO
var white := true
var shortname := ""
var mininame := "♙"
var has_moved := false
var frameon := false
var team := "w"

onready var sprite := $Sprite
onready var tween := $Tween
onready var anim := $AnimationPlayer
onready var rotate := $RotatePlayer
onready var colorrect := $ColorRect
onready var frame := $Sprite/Frame


func _ready() -> void:
	team = "w" if white else "b"
	var tmp: Array = Utils.get_node_name(self)
	mininame = tmp[0]
	shortname = tmp[1]
	rect_min_size = Globals.grid.piece_size
	rect_size = rect_min_size
	rect_pivot_offset = Globals.grid.piece_size / 2
	frame.modulate = Globals.grid.overlay_color
	colorrect.color = Globals.grid.overlay_color
	sprite.flip_v = Globals.grid.flipped
	sprite.flip_h = Globals.grid.flipped
	load_texture()


func set_zindex(zindex: int, obj: CanvasItem = self):
	VisualServer.canvas_item_set_z_index(obj.get_canvas_item(), zindex)


func load_texture(
	path := "%s%s%s.png" % [Globals.grid.ASSETS_PATH, team, shortname.to_upper()]
) -> void:
	sprite.texture = load(path)


func clicked() -> void:
	colorrect.show()
	set_circle(get_moves())
	set_circle(get_attacks(), "take")


func clear_clicked() -> void:
	colorrect.hide()
	Globals.grid.clear_fx()


func move(newpos: Vector2) -> void:  # dont use directly; use moveto
	tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		newpos * Globals.grid.piece_size,
		0.3,
		Tween.TRANS_BACK
	)
	var signresult := int(sign(real_position.x - newpos.x))
	if signresult == 1:
		rotate.play("Right")
	elif signresult == -1:
		rotate.play("Left")
	anim.play("Move")
	tween.start()


func moveto(pos: Vector2, instant := false) -> void:
	Globals.grid.matrix[real_position.y][real_position.x] = null
	Globals.grid.matrix[pos.y][pos.x] = self
	if !instant:
		move(pos)
		real_position = pos
		SoundFx.play("Move")
	else:
		has_moved = true
		real_position = pos


func update_visual_position():
	rect_position = real_position * Globals.grid.piece_size


func pos_around(around_vector: Vector2) -> Vector2:
	return real_position + around_vector


static func all_dirs() -> PoolVector2Array:
	return PoolVector2Array(
		[
			Vector2.UP,
			Vector2.DOWN,
			Vector2.LEFT,
			Vector2.RIGHT,
			Vector2(1, 1),
			Vector2(1, -1),
			Vector2(-1, 1),
			Vector2(-1, -1)
		]
	)


func traverse(
	arr: PoolVector2Array = [], no_enemys := false, check_spots_check := true
) -> PoolVector2Array:
	var circle_array: PoolVector2Array = []
	for i in arr:
		var pos := real_position
		while true:
			pos += i
			if !is_on_board(pos):
				break
			if at_pos(pos) != null:
				if at_pos(pos).white == white:  # fren
					break
				# certaintly a enemy
				if no_enemys:  # do we want enemys?
					break
				circle_array.append(pos)
				break
			if check_spots_check and checkcheck(pos):
				continue
			circle_array.append(pos)
	return circle_array


static func at_pos(vector: Vector2) -> Piece:
	if is_on_board(vector):
		return Globals.grid.matrix[vector.y][vector.x]
	return null


func can_move() -> bool:  # checks if you can legally move
	if get_moves().size() != 0 or get_attacks().size() != 0:
		return true
	return false


func get_moves(_no_enemys := false, _check_spots_check := true) -> PoolVector2Array:  # @Override
	return PoolVector2Array()


func get_attacks(check_spots_check := true) -> PoolVector2Array:  # @Override
	var moves := get_moves(false, check_spots_check)  # assumes the attacks are same as moves
	var final: PoolVector2Array = []
	for i in moves:
		if at_pos(i) != null:
			if at_pos(i).white != white:  # attack ze enemie
				if check_spots_check and checkcheck(i):
					continue
				final.append(i)
	return final


func can_attack_piece(piece: Piece) -> bool:  ##i cant use pos in get_attacks for some bizarre reasons
	for pos in get_attacks(false):
		if at_pos(pos) == piece:
			return true
	return false


func can_touch(pos: Vector2, attack := true, move := true) -> bool:
	if attack and move:
		return pos in get_attacks() or pos in get_moves()
	elif attack:
		return pos in get_attacks()
	elif move:
		return pos in get_moves()
	else:
		return false


static func create_move_circles(pos: Vector2) -> void:
	Globals.grid.get_background_element(pos).set_circle(true)  # make the move circle


static func create_take_circles(spot: Piece) -> void:  # create take circles
	spot.set_frame()  # turn on the little take frame on the piece, to show its takeable


static func set_circle(positions: Array, type := "move") -> void:
	for pos in positions:
		var spot := at_pos(pos)  # get the piece at the position
		if type == "move":
			create_move_circles(pos)  # create the move circle
		elif type == "take":
			create_take_circles(spot)  # if the king is in check, return true


func checkcheck(pos) -> bool:  # moves to position, then checks if your king is in check
	# TODO: figure out why this function isnt working with can_move()
	var mat: Array = Globals.grid.matrix.duplicate(true)  # make a copy of the matrix
	Globals.grid.matrix[real_position.y][real_position.x] = null  # remove the piece from the matrix
	Globals.grid.matrix[pos.y][pos.x] = self  # move the piece to the new position
	if Globals.grid.check_in_check():  # if you are still in check
		Globals.grid.matrix = mat  # revert changes on the matrix
		return true
	Globals.grid.matrix = mat
	return false


static func is_on_board(vector: Vector2) -> bool:  # limit the vector to the board
	if vector.y < 0 or vector.y > 7 or vector.x < 0 or vector.x > 7:
		return false
	return true


func take(piece: Piece, instant := false) -> void:
	clear_clicked()
	piece.took(instant)
	moveto(piece.real_position, instant)


func took(instant := false) -> void:  # called when piece is taken
	Globals.grid.matrix[real_position.y][real_position.x] = null
	if !instant:
		SoundFx.play("Capture")
		anim.play("Took")


func set_frame(value := true) -> void:
	frameon = value
	frame.visible = value

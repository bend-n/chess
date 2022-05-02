extends Piece
class_name Pawn, "res://assets/pieces/california/wP.png"

const promotables := ["Q.png", "N.png", "R.png", "B.png"]

var twostepfirstmove := false
var just_set := false
var enpassant := []

onready var whiteint := 1 if white else -1
onready var sprites := []


func _ready():
	Events.connect("turn_over", self, "_on_turn_over")
	Events.connect("just_before_turn_over", self, "_just_before_turn_over")
	sprite.position = Globals.grid.piece_size / 2
	for i in range(0, 4):  # add 3 sprites
		var newsprite = load("res://ClickableSprite.tscn").instance()
		newsprite.position = (sprite.position + Vector2(0, (i * Globals.grid.piece_size.y) * whiteint))
		newsprite.name = "Sprite%s" % str(i)
		newsprite.connect("clicked", self, "handle_sprite_input_event")
		newsprite.z_index = 5
		newsprite.hide()
		add_child(newsprite)
		sprites.append(newsprite)


func moveto(position, real = true, take = false):
	# check if 2 step
	if real and !twostepfirstmove and !has_moved:
		if white and real_position.y - position.y == 2:
			twostepfirstmove = true
			just_set = true
		if !white and position.y - real_position.y == 2:
			twostepfirstmove = true
			just_set = true
	.moveto(position, real, take)


func get_moves():
	var points := [Vector2.UP, Vector2.UP * 2]
	var moves := []
	for i in range(len(points)):
		var point: Vector2 = points[i]
		point *= whiteint
		point = pos_around(point)
		if is_on_board(point) and at_pos(point) == null:
			if i == 1 and has_moved or at_pos(pos_around(points[0] * whiteint)) != null:
				continue
			if check_spots_check and checkcheck(point):
				continue
			if is_on_board(point):
				moves.append(point)
	moves.append_array(en_passant())
	return moves


func can_promote(position):
	if position.y >= 7 or position.y <= 0:
		return true
	return false


func passant(position):
	enpassant.clear()
	moveto(position)


func get_attacks():
	var points := [Vector2.UP + Vector2.RIGHT, Vector2.UP + Vector2.LEFT]
	var moves := []
	for i in range(len(points)):
		var point: Vector2 = points[i]
		point *= whiteint
		point = pos_around(point)
		if !is_on_board(point):
			continue
		if check_spots_check and checkcheck(point):
			continue
		if at_pos(point) != null and at_pos(point).white != white:
			moves.append(point)
	en_passant()
	return moves


func en_passant(turncheck = true):  # in passing
	var passants := [pos_around(Vector2.LEFT), pos_around(Vector2.RIGHT)]
	var moves := []
	for i in passants:
		if !is_on_board(i) or !at_pos(i):
			continue
		var spot = at_pos(i)
		if spot.white == white or !Utils.is_pawn(spot):
			continue
		if turncheck and white != Globals.turn:
			continue
		if !spot.twostepfirstmove:
			continue
		if check_spots_check and checkcheck(i):
			continue
		var position: Vector2 = i + (Vector2.UP * whiteint)
		if !at_pos(position):
			moves.append(position)
		enpassant.append([position, spot])
	return moves


func promote(position, type):
	if type == "take":
		take(at_pos(position))
	else:
		moveto(position)
	for i in range(len(promotables)):
		sprites[i].sprite.texture = load("%s%s%s" % [Globals.grid.ASSETS_PATH, team.to_lower(), promotables[i]])
		sprites[i].show()


func handle_sprite_input_event(node):
	var script = piece(promotables[sprites.find(node)][0])
	Globals.grid.make_piece(real_position, script, white)
	Globals.grid.turn_over()
	clear_clicked()
	queue_free()


func piece(string):
	match string:
		"Q":
			return "res://pieces/Queen.gd"
		"N":
			return "res://pieces/Knight.gd"
		"R":
			return "res://pieces/Rook.gd"
		"B":
			return "res://pieces/Bishop.gd"


func _on_turn_over():
	if just_set:
		just_set = false
		return
	if twostepfirstmove:
		twostepfirstmove = false


func _just_before_turn_over():
	var had_a_enpassant := len(enpassant) > 0
	enpassant.clear()
	if !had_a_enpassant:  # scuffed method to check if enpassant is possible
		en_passant(false)
	var temporary := []
	for i in enpassant:
		temporary.append(i[0])
	if !temporary:
		return
	if white:
		Globals.grid.matrix[8].wcep.append_array(temporary)
	else:
		Globals.grid.matrix[8].bcep.append_array(temporary)

extends Piece
class_name Pawn, "res://assets/pieces/california/wP.png"

const promotables := "QNRB"

var twostepfirstmove := false
var just_set := false
var enpassant: Array = []

var promoteposition := Vector2()
var promotetake := false

onready var whiteint := 1 if white else -1
onready var sprites := []
onready var darken: ColorRect = $"../../Darken"


func _ready() -> void:
	Globals.pawns.append(self)
	Events.connect("turn_over", self, "_on_turn_over")
	Events.connect("just_before_turn_over", self, "_just_before_turn_over")
	sprite.position = Globals.grid.piece_size / 2
	for i in range(0, 4):  # add 3 sprites
		var newsprite: Node2D = load("res://ui/ClickableSprite.tscn").instance()
		newsprite.position = (sprite.position + Vector2(0, (i * Globals.grid.piece_size.y) * whiteint))
		newsprite.connect("clicked", self, "handle_sprite_input_event", [newsprite])
		newsprite.z_index = 5  # its not a texturebutton so i can use this
		newsprite.hide()
		add_child(newsprite)
		sprites.append(newsprite)


func _exit_tree() -> void:
	var find: int = Globals.pawns.find(self)
	if find != -1:
		Globals.pawns.remove(find)


func moveto(position: Vector2, real := true, take := false, override_moveto := false) -> void:
	# check if 2 step
	if real:
		if !twostepfirstmove and !has_moved:
			if white and real_position.y - position.y == 2:
				twostepfirstmove = true
				just_set = true
			if !white and position.y - real_position.y == 2:
				twostepfirstmove = true
				just_set = true
	.moveto(position, real, take, override_moveto)
	if real:
		Globals.reset_halfmove()


func get_moves(_var := false, check_spots_check := true) -> PoolVector2Array:
	var points := [Vector2.UP, Vector2.UP * 2]
	var moves: PoolVector2Array = []
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


static func can_promote(position: Vector2) -> bool:
	return position.y >= 7 or position.y <= 0


func passant(position: Vector2) -> void:
	enpassant.resize(0)
	moveto(position)


func get_attacks(check_spots_check := true) -> PoolVector2Array:
	var points := [Vector2.UP + Vector2.RIGHT, Vector2.UP + Vector2.LEFT]
	var moves: PoolVector2Array = []
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


func en_passant(turncheck := true, check_spots_check := true) -> Array:  # in passing
	var passants := [pos_around(Vector2.LEFT), pos_around(Vector2.RIGHT)]
	var moves := []
	for i in passants:
		if !is_on_board(i) or !at_pos(i):
			continue
		var spot := at_pos(i)
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


func promote(position: Vector2, type: String) -> void:
	if type == "take":
		at_pos(position).hide()
	move(position)  # only move the visuals
	promoteposition = position
	darken.show()
	for i in range(len(promotables)):
		sprites[i].sprite.texture = load(
			"%s%s%s.png" % [Globals.grid.ASSETS_PATH, team.to_lower(), promotables[i]]
		)
		sprites[i].name = promotables[i]
		sprites[i].show()


func handle_sprite_input_event(node: Node2D) -> void:
	darken.hide()
	var promote_to := node.name
	var first := (
		algebraic_move_notation(promoteposition)
		if !promotetake
		else algebraic_take_notation(promoteposition, real_position)
	)
	Log.debug(promote_to)
	var notation := "%s=%s" % [first, promote_to]
	Globals.network.send_move_packet(
		{
			"start_position": real_position,
			"destination": promoteposition,
			"become": promote_to,
			"notation": notation,
			"white": white
		},
		Network.MOVEHEADERS.promote
	)


static func piece(string: String) -> String:
	match string:
		"Q":
			return "Queen"
		"N":
			return "Knight"
		"R":
			return "Rook"
		"B":
			return "Bishop"
		_:
			return "Piece"


func _on_turn_over() -> void:
	if just_set:
		just_set = false
		return
	if twostepfirstmove:
		twostepfirstmove = false


func _just_before_turn_over() -> void:
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

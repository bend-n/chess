extends Piece
class_name Pawn, "res://assets/pieces/california/wP.png"

const promotables := "QNRB"

var just_double_stepped := false
var just_set := false
var enpassant: Array = []

var promoteposition := Vector2()
var promotetake := false

onready var whiteint := 1 if white else -1
onready var sprites := []
onready var darken: ColorRect = $"../../Darken"
onready var previews = $Popup/Previews
onready var popup: Popup = $Popup


func _ready() -> void:
	Globals.pawns.append(self)
	Events.connect("turn_over", self, "_on_turn_over")
	for i in range(4):  # add 4 sprites
		var newsprite: TextureButton = load("res://ui/PromotionPreview.tscn").instance()
		newsprite.texture_normal = load(
			"res://assets/pieces/%s/%s%s.png" % [Globals.piece_set, team.to_lower(), promotables[i]]
		)
		newsprite.name = promotables[i]
		newsprite.connect("pressed", self, "_pressed", [newsprite.name])
		previews.add_child(newsprite)
		sprites.append(newsprite)


func open_previews() -> void:
	var rect := popup.get_global_rect()
	rect.position = rect_global_position
	popup.popup(rect)


func _exit_tree() -> void:
	Globals.pawns.erase(self)


func moveto(position: Vector2, instant := false) -> void:
	# check if 2 step
	if !just_double_stepped and !has_moved:
		just_double_stepped = true
		just_set = true
	.moveto(position, instant)


func get_moves(_var := false, check_spots_check := true) -> PoolVector2Array:
	var points: PoolVector2Array = [Vector2.UP, Vector2.UP * 2]
	var moves: PoolVector2Array = []
	for i in range(len(points)):
		var point := points[i]
		point *= whiteint
		point = pos_around(point)
		if at_pos(point) == null:
			if (
				(i == 1 and (has_moved or at_pos(pos_around(points[0] * whiteint)) != null))
				or (check_spots_check and checkcheck(point))
				or !is_on_board(point)
			):
				continue
			moves.append(point)
	moves.append_array(en_passant())
	return moves


static func can_promote(position: Vector2) -> bool:
	return position.y >= 7 or position.y <= 0


func passant(position: Vector2, instant := false) -> void:
	var to_take = position + Vector2(0, whiteint)
	at_pos(to_take).took(instant)
	enpassant.resize(0)
	moveto(position, instant)


func valid_to_passant_take(piece) -> bool:
	return !piece or !Utils.is_pawn(piece) or piece.white != white or !piece.just_double_stepped


func get_attacks(check_spots_check := true) -> PoolVector2Array:
	var points := [Vector2.UP + Vector2.RIGHT, Vector2.UP + Vector2.LEFT]
	var moves: PoolVector2Array = []
	for i in range(len(points)):
		var point: Vector2 = points[i]
		point *= whiteint
		point = pos_around(point)
		if at_pos(point) == null or at_pos(point).white == white or (check_spots_check and checkcheck(point)):
			continue
		moves.append(point)
	return moves


func en_passant(turncheck := true, check_spots_check := true) -> Array:  # in passing
	if turncheck and white != Globals.turn:
		return []
	var passants := [pos_around(Vector2.LEFT), pos_around(Vector2.RIGHT)]
	var moves := []
	for i in passants:
		var spot := at_pos(i)
		if (
			!spot  # spot doesnt exist
			or spot.white == white  # spot is my team
			or !Utils.is_pawn(spot)  #spot isnt a pawn
			or !spot.just_double_stepped  # spot didnt just double step
			or (check_spots_check and checkcheck(i))
		):  # moving there would put me in check
			continue
		var position: Vector2 = i + (Vector2.UP * whiteint)
		if !at_pos(position):
			moves.append(position)
		enpassant.append([position, spot])
	return moves


func promote(position: Vector2, type: String) -> void:
	if type == "take":
		at_pos(position).hide()  # only hide the visuals
	move(position)  # only move the visuals
	promoteposition = position  # save the position
	darken.show()  # open fx
	yield(tween, "tween_completed")  # wait till were done moving to the new position
	open_previews()  # open the previews


func promote_to(promote_to: int, is_capture: bool, position: Vector2, instant := false):
	if is_capture and at_pos(position):
		at_pos(position).took(instant)
	clear_clicked()
	Globals.grid.make_piece(position, promote_to, white)
	took()


func _pressed(promote_to: String) -> void:
	previews.hide()
	darken.hide()
	var is_cap = at_pos(promoteposition) != null
	var mov = Move.new(SanParser.PAWN, [real_position, promoteposition], is_cap)
	mov.promotion = SanParse.from_str(promote_to)
	PacketHandler.send_mov(mov)


func _on_turn_over() -> void:
	if just_set:
		just_set = false
		return
	if just_double_stepped:
		just_double_stepped = false

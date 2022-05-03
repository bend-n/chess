extends Piece
class_name King, "res://assets/pieces/california/wK.png"

var castle_check := true
var can_castle := []


func _ready() -> void:
	Events.connect("just_before_turn_over", self, "just_before_over")


func get_moves() -> Array:
	var moves := []
	for i in all_dirs():
		var spot: Vector2 = pos_around(i)
		if is_on_board(spot):
			if no_enemys and at_pos(spot):
				continue
			if check_spots_check and checkcheck(spot):
				continue
			moves.append(spot)
	if castle_check and !Globals.in_check:  # make sure this is only called when clicking
		moves.append_array(castleing())
	return moves


func just_before_over() -> void:  # assign metadata for threefold repetition draw check
	castleing()
	if can_castle.size() > 0:
		for i in can_castle:
			if i[3] == "O-O-O":
				if white:
					Globals.grid.matrix[8].wccl = true
				else:
					Globals.grid.matrix[8].bccl = true
			else:
				if white:
					Globals.grid.matrix[8].wccr = true
				else:
					Globals.grid.matrix[8].bccr = true


func castleing(justcheckrooks = false) -> Array:
	if has_moved:
		return []
	var moves := []
	var rooks := [pos_around(Vector2.RIGHT * 3), pos_around(Vector2.LEFT * 4)]
	var labels = ["Q", "K"]
	var rook_motion := [pos_around(Vector2.RIGHT), pos_around(Vector2.LEFT)]
	var king_moveto_spots := [Vector2.RIGHT, Vector2.LEFT]  # O-O  and O-O-O respectivel
	for i in range(len(rooks)):
		if !is_on_board(rooks[i]):
			continue
		var rook = at_pos(rooks[i])
		if !rook is Rook:
			continue
		if rook.has_moved:
			continue
		if justcheckrooks:
			moves.append(labels[i])
			continue
		var direction: Vector2 = king_moveto_spots[i]
		var posx2: Vector2 = pos_around(direction * 2)
		var pos: Vector2 = pos_around(direction)
		if at_pos(posx2) or at_pos(pos):
			continue
		if checkcheck(posx2) or checkcheck(pos):
			continue
		can_castle.append([posx2, rook, rook_motion[i], "O-O-O" if i == 1 else "O-O"])
		moves.append(posx2)
	return moves


func castle(position) -> String:
	var return_string = ""
	if can_castle.size() == 1:
		return_string = can_castle[0][3]
	else:
		for i in can_castle:
			if i[0] == position:
				return_string = i[3]
				break
	override_moveto = true
	can_castle.clear()
	moveto(position)
	override_moveto = false
	return return_string


func can_move() -> bool:  # checks if you can legally move
	castle_check = false
	var can: bool = .can_move()
	castle_check = true
	return can


func get_attacks() -> Array:
	castle_check = false
	var final: Array = .get_attacks()
	castle_check = true
	return final

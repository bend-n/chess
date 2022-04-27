extends Piece
class_name Queen


func get_moves():
	return traverse(all_dirs())


func get_attacks():  # @Override
	var moves = get_moves()  # assumes the attacks are same as moves
	var final = []
	print("getting  attacks from moves, moves: " + str(moves))
	for i in moves:
		if at_pos(i) != null and at_pos(i).white != white:
			final.append(i)
	print("final: " + str(final))
	return final


func can_check_king(king):
	print("queen looking for king")
	check_spots_check = false
	print("starting the loop")
	var attacks = get_attacks()
	print("get attacks is: " + str(attacks))
	# assert(get_attacks())
	for attack in attacks:
		if at_pos(attack) == king:
			print("queen found king")
			check_spots_check = true
			return true
		print(str(attack) + " was not king")
	check_spots_check = true
	return false


func _ready():
	._ready()
	shortname = "q" + team

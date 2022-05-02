signal newmove
extends Node

var turn_moves: PoolStringArray = []
var turns_moves := []

var counter := 0


func _ready():
	Events.connect("turn_over", self, "_on_turn_over")


func is_pawn(inode):
	return inode is Pawn


func add_move(move):
	if turn_moves.size() == 0:
		turn_moves.append(str(Globals.white_turns + 1) + ". " + move)
	else:
		turn_moves.append(move)
	emit_signal("newmove", move)


func calculate_algebraic_position(real_position):
	return char(65 + (real_position.x)).to_lower() + str(8 - real_position.y)


func get_node_name(node):
	if is_pawn(node):
		return ["♙", "p"] if node.white else ["♟", "p"]
	elif node is King:
		return ["♔", "K"] if node.white else ["♚", "K"]
	elif node is Queen:
		return ["♕", "Q"] if node.white else ["♛", "Q"]
	elif node is Rook:
		return ["♖", "R"] if node.white else ["♜", "R"]
	elif node is Bishop:
		return ["♗", "B"] if node.white else ["♝", "B"]
	elif node is Knight:
		return ["♘", "N"] if node.white else ["♞", "N"]
	else:
		return ["", ""]


func walk_dir(path = "res://assets/pieces"):  # walk the directory, finding the asset packs
	var folders := []  # init the folders
	var dir := Directory.new()  # init the directory
	if dir.open(path) == OK:  # open the directory
		dir.list_dir_begin()  # list the directory
		var file_name := dir.get_next()  # get the next file
		while file_name != "":  # while there is a file
			if dir.current_is_dir():  # if the current is a directory
				if file_name == "." or file_name == "..":  # if it is a dot or dot dot
					file_name = dir.get_next()  # get the next file
					continue
				folders.append(file_name)  # add the folder
			file_name = dir.get_next()  # get the next file
	else:
		printerr("An error occurred when trying to access the path " + path)  # print the error
	return folders  # return the folders


func format_seconds(time: float, use_milliseconds: bool = false):
	var minutes := time / 60
	var seconds := fmod(time, 60)

	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]


func round_place(num, places):
	return round(num * pow(10, places)) / pow(10, places)


func _on_turn_over():
	counter += 1
	if counter >= 2:
		counter = 0
		turns_moves.append(turn_moves.join(" "))
		turn_moves.resize(0)

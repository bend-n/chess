extends Node2D
class_name Piece, "res://assets/california/wP.png"

var real_position = Vector2.ZERO
var white := true
var realname = "pawn"
var has_moved = false
var sprite

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
	

func clear_clicked(): # TODO: fix this shit
	colorrect.hide()
	Globals.grid.clear_circles()
	Globals.grid.clear_frames()
	
func move(newpos: Vector2): # dont use directly; use moveto
	has_moved = true
	global_position = newpos * Globals.grid.piece_size

func moveto(position):
	Globals.grid.matrix[real_position.y][real_position.x] = null
	Globals.grid.matrix[position.y][position.x] = self
	real_position = position
	move(position)


func pos_around(around_vector):
	return real_position + around_vector

func create_circles():
	# for motion
	match realname:
		"pawn":
			var carry = [pos_around(Vector2.UP)]
			if !has_moved:
				carry.append(pos_around(Vector2(0, -2)))
			set_circle(carry)
			# deal with the take logic
			carry = []
			var takes = [pos_around(Vector2(-1, -1)), pos_around(Vector2(1, -1))]
			for i in takes:
				i = clamp_vector(i)
				if i == null:
					continue
				var pos = Globals.grid.matrix[i.y][i.x]
				if pos and !pos.white:
					carry.append(i)
			print("takeable: ", carry)
			set_circle(carry, "take")
		"king":
			var carry = [pos_around(Vector2.UP), pos_around(Vector2.DOWN), pos_around(Vector2.LEFT), pos_around(Vector2.RIGHT)]
			# add diagonals
			carry.append(pos_around(Vector2(-1, -1)))
			carry.append(pos_around(Vector2(1, -1)))
			carry.append(pos_around(Vector2(-1, 1)))
			carry.append(pos_around(Vector2(1, 1)))
			set_circle(carry)
			set_circle(carry, "take") # king ez

func set_circle(positions: Array, type: = "move"):
	for i in range(len(positions)):
		var pos = clamp_vector(positions[i])
		if pos == null:
			continue
		var spot = Globals.grid.matrix[pos.y][pos.x]
		if spot and type == "move":
			continue
		if type == "move":
			# print("creating move circle at", pos)
			Globals.grid.background_matrix[pos.x][pos.y].set_circle(true)
		elif type == "take":
			print("creating take circle at", pos)
			if spot and !spot.white:
				spot.set_frame(true)

func set_frame(boolean):
	frame.visible = boolean

func clamp_vector(vector :Vector2):
	if vector.y < 0 or vector.y > 7 or vector.x < 0 or vector.x > 7:
		return null
	vector.x = clamp(vector.x, 0, 7)
	vector.y = clamp(vector.y, 0, 7)
	return vector

func take(piece:Piece):
	var piecepos = piece.real_position
	piece.queue_free()
	moveto(piecepos)

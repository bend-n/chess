extends Node2D
class_name Piece, "res://assets/california/wP.png"

var real_position = Vector2.ZERO
var white := true
var realname = "pawn"
var has_moved = false
var sprite

onready var colorrect = $ColorRect


func _ready():
	colorrect.color = Globals.grid.overlay_color
	colorrect.rect_size = Globals.grid.piece_size


func move(newpos: Vector2):
	has_moved = true
	global_position = newpos * Globals.grid.piece_size


func clicked():
	colorrect.show()
	create_circles()
	print(realname, " was clicked")


func clear_clicked():
	colorrect.hide()
	Globals.grid.clear_circles()


func moveto(position):  # called when already clicked, and clicked again
	Globals.grid.matrix[real_position.y][real_position.x] = null
	Globals.grid.matrix[position.y][position.x] = self
	real_position = position
	move(position)


func create_circles():
	# for motion
	match realname:
		"pawn":
			var carry = [real_position - Vector2(0, 1)]
			if !has_moved:
				carry.append(real_position - Vector2(0, 2))
			set_circle(carry)


func set_circle(positions: Array):
	for i in range(len(positions)):
		var pos = positions[i]
		if Globals.grid.matrix[pos.y][pos.x]:
			print(Globals.grid.matrix[pos.y][pos.x], " is in the way")
			continue
		print("creating circle at", pos)
		Globals.grid.background_matrix[pos.x][pos.y].set_circle(true)

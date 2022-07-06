extends Node
class_name MaterialLabelManager

const PIECE_SCORES = {
	p = 1,
	n = 3,
	b = 3,
	r = 5,
	q = 9,
	k = 0,
}

export(NodePath) var white_path
onready var w: MaterialLabel = get_node(white_path)
export(NodePath) var black_path
onready var b: MaterialLabel = get_node(black_path)


func _ready():
	Events.connect("turn_over", self, "show_material_imbalance")


func get_material_diff() -> Dictionary:
	var diff := {
		w = {k = 0, q = 0, r = 0, b = 0, n = 0, p = 0},
		b = {k = 0, q = 0, r = 0, b = 0, n = 0, p = 0},
	}
	for i in Globals.grid.chess.SQUARE_MAP.values():
		var p = Globals.grid.chess.board[i]
		if !p:
			continue
		var them = diff[Chess.__swap_color(p.color)]
		if them[p.type] > 0:
			them[p.type] -= 1
		else:
			diff[p.color][p.type] += 1
	return diff


func get_material_score(pieces: Dictionary) -> int:
	var score = 0
	for c in pieces:  # color
		for p in pieces[c]:  # dictionary of pieces : {p=0}
			for i in pieces[c][p]:  # number of pieces
				score += PIECE_SCORES[p] * (1 if c == "w" else -1)
	return score


func show_material_imbalance():
	var d = get_material_diff()
	var score = get_material_score(d)
	w.display(d.w, score if score > 0 else 0)
	b.display(d.b, abs(score) if score < 0 else 0)

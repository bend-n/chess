extends HBoxContainer

onready var number := $"Number/Number"
onready var sans = [$"San1/San1", $"San2/San2"]

var moves_added = 0


func add_move(move: String) -> void:
	sans[moves_added].text = move
	moves_added += 1


func pop_move():
	moves_added -= 1
	if moves_added == 0:
		queue_free()
	sans[moves_added].text = ""

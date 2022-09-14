extends LineEdit

onready var checkmark: Label = $"../Checkmark"

signal pgn_selected(m_array)


func _init() -> void:
	connect("text_changed", self, "text_changed")


func text_changed(new_text: String) -> void:
	if !new_text:
		checkmark.hide()
		return
	var status = validate_pgn(new_text)
	checkmark.show()
	if status:
		emit_signal("pgn_selected", status)
		checkmark.text = ""
	else:
		checkmark.text = ""


func validate_pgn(p: String):
	var pgn_parser := PGN.new()
	var parsed = pgn_parser.parse(p)
	if parsed != null:
		var c = Chess.new()
		if c.load_pgn(text) == OK and !c.game_over():
			return parsed.moves
	return false

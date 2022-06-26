extends LineEdit

signal pgn_selected(m_array)


func _text_entered(new_text: String):
	var status = validate_pgn(new_text)
	if status:
		emit_signal("pgn_selected", status)
	else:
		text = "invalid pgn"


func validate_pgn(p: String):
	var parsed = Pgn.parse(p)
	if parsed == null:
		return false
	else:
		return parsed.moves  # TODO: simulate the pgn and such nonsense

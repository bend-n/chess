extends Button

onready var pw := $"../Password"


func _toggled(p: bool) -> void:
	pw.secret = p
	text = "" if p else ""

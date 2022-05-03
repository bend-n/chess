extends LineEdit
class_name FENLabel


func _ready() -> void:
	Utils.connect("newfen", self, "on_new_fen")
	context_menu_enabled = false


func on_new_fen(fen) -> void:
	text = fen

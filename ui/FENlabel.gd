extends LineEdit
class_name FENLabel


func _ready() -> void:
	Utils.connect("newfen", self, "on_new_fen")


func on_new_fen(fen: String) -> void:
	text = fen

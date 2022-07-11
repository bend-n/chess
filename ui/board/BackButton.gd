extends Button
class_name BackButton


func _ready():
	Events.connect("game_over", self, "game_over")


func _pressed():
	Events.emit_signal("go_back", "", true)


func game_over(_reason: String, _ok: bool) -> void:
	show()

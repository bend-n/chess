extends CenterContainer
class_name BackButton

var button := Button.new()


func _ready():
	add_child(button)
	Events.connect("game_over", self, "_game_over")
	button.text = "go back"
	button.connect("pressed", Events, "emit_signal", ["go_back", "", true])


func _game_over(_why: String) -> void:
	show()

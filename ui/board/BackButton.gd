extends CenterContainer
class_name BackButton

var button := Button.new()


func _ready():
	add_child(button)
	button.text = "go back"
	button.connect("pressed", Events, "emit_signal", ["go_back", "", true])

extends Button


func _ready():
	connect("pressed", Events, "emit_signal", ["go_back", "", true])

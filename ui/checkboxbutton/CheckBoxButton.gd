extends Button
class_name CheckBoxButton

onready var tx := text

export(String) var off_icon = ""
export(String) var on_icon = ""


func _toggled(p: bool):
	text = (on_icon if p else off_icon) + tx


func _ready():
	assert(toggle_mode)
	_toggled(pressed)

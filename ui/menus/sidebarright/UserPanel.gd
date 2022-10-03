extends MarginContainer
class_name UserPanel

onready var flag_display = $"%Flag"
onready var name_display = $"%Name"
onready var nps_display = $"%Nps"

var flag := "rainbow" setget set_flag
var _name := "name" setget set_name
var nps := 0 setget set_nps


func set_flag(newflag: String) -> void:
	flag = newflag
	flag_display.texture = load("res://assets/flags/%s.png" % flag)


func set_name(newname: String) -> void:
	_name = newname
	name_display.text = _name


func set_nps(new_nps: int) -> void:
	if new_nps == 0:
		nps_display.hide()
	else:
		nps_display.show()
		nps_display.text = "%dn/s" % new_nps
	nps = new_nps

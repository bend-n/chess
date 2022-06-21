extends PanelContainer

onready var flag_display = $MC/H/Flag
onready var name_display = $MC/H/Name

var flag := "rainbow" setget set_flag
var _name := "name" setget set_name


func set_flag(newflag: String):
	flag = newflag
	flag_display.texture = load("res://assets/flags/%s.png" % flag)


func set_name(newname: String):
	_name = newname
	name_display.text = _name

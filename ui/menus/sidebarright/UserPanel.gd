extends MarginContainer
class_name UserPanel

onready var flag_display = $"%Flag"
onready var name_display = $"%Name"
onready var nps_display = $"%Nps"
onready var thinking_display = $"%ThinkingProgress"

var flag := "rainbow" setget set_flag
var _name := "name" setget set_name
var nps := 0 setget set_nps
var thinking := 0 setget set_thinking


func set_flag(newflag: String) -> void:
	flag = newflag
	flag_display.texture = load("res://assets/flags/%s.png" % flag)


func set_name(newname: String) -> void:
	_name = newname
	name_display.text = _name


func set_nps(new_nps: int) -> void:
	if nps == new_nps:
		return
	if new_nps == 0:
		nps_display.hide()
	else:
		nps_display.show()
		if OS.has_feature('JavaScript'):
			var localized = JavaScript.eval("(%d).toLocaleString(document.documentElement.lang || 'en')" % new_nps)
			nps_display.text = "%sn/s" % (localized if localized else format_n(new_nps)) # fallback
		else:
			nps_display.text = "%sn/s" % format_n(new_nps)
	nps = new_nps


func format_n(n: int) -> String:
	var strn := str(n)
	if n == 0:
		return strn
	var lenn := len(strn)
	var i := 1
	while (3 * i) < lenn:
		i += 1
		strn = strn.insert(i, ",")
	return strn

func set_thinking(new_thinking: int) -> void:
	if new_thinking == thinking:
		return
	if new_thinking == 0:
		thinking_display.hide()
		thinking_display.value = 0
	else:
		thinking_display.show()
		create_tween().tween_property(thinking_display, "value", float(new_thinking), .25)

	thinking = new_thinking

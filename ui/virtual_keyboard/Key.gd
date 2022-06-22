extends KeyUtils
class_name Key

var scncode = 0
var unicode = 0
export(String) var key = "" setget set_key
export(String) var shift_key = "" setget set_shift_key
export(bool) var shift_on_capslock = false

var shift_scncode := 0
var shift_unicode := 0

var shf_p := false setget set_shift_pressed  # is shift pressed


func set_shift_pressed(is_pressed: bool) -> void:
	if shf_p != is_pressed:
		shf_p = is_pressed
		text = shift_key if shf_p else key


func set_shift_key(new_shift_key: String) -> void:
	if len(new_shift_key) == 1:
		shift_key = new_shift_key
		shift_unicode = ord(shift_key)
		shift_scncode = OS.find_scancode_from_string(shift_key)
	elif new_shift_key:
		print_debug("this size is incorrect")


func _input(event: InputEvent):
	if event is InputEventKey:
		if event.scancode == KEY_SHIFT:
			if shift_on_capslock and shf_p and Input.is_action_pressed("caps"):
				return
			set_shift_pressed(event.pressed)
		if event.scancode == KEY_CAPSLOCK and shift_on_capslock:
			if Input.is_action_pressed("shift") and shf_p:
				return
			set_shift_pressed(event.pressed)


func set_key(new_key: String) -> void:
	if len(new_key) == 1:
		key = new_key
		name = new_key if new_key.validate_node_name() else name
		text = new_key
		unicode = ord(new_key)
		scncode = OS.find_scancode_from_string(key)
	elif new_key:
		print_debug("this size is incorrect")


func pressed():
	simulate_key_input_event(shift_scncode if shf_p else scncode, shift_unicode if shf_p else unicode)


func released():
	simulate_key_input_event(shift_scncode if shf_p else scncode, shift_unicode if shf_p else unicode, false)


func _ready():
	if !shift_key:
		shift_key = key.to_upper()  # x -> X

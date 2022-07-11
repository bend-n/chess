extends Control
class_name UsernamePass

onready var username = $Username
onready var pw = $H/Password

signal done


func update_data(data: Dictionary) -> void:
	username.text = data.user
	username.caret_position = data.user_caret
	pw.text = data.pasw
	pw.caret_position = data.pasw_caret


func export_data() -> Dictionary:
	return {
		"user": username.text,
		"user_caret": username.caret_position,
		"pasw": pw.text,
		"pasw_caret": pw.caret_position
	}


func set_enabled(enabled: bool) -> void:
	username.editable = enabled
	pw.editable = enabled


func _entered(_nt := "") -> void:
	if username.text and pw.text:
		emit_signal("done")

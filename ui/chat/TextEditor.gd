extends Container
class_name TextEditor

var text setget set_text, get_text


func set_text(new_text: String) -> void:
	textedit.text = new_text
	_text_changed()


func get_text() -> String:
	return textedit.text


signal done(text)

export(NodePath) var textedit_path
onready var textedit: TextEdit = get_node(textedit_path)
export(NodePath) var placeholder_path
onready var placeholder := get_node(placeholder_path)


func _text_changed() -> void:
	placeholder.visible = len(textedit.text) == 0


func _on_text_send(msg: String) -> void:
	emit_signal("done", msg)

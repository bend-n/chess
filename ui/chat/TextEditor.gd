extends Container
class_name TextEditor

var text setget set_text, get_text


func set_text(new_text: String) -> void:
	textedit.text = new_text
	_text_changed()


func get_text() -> String:
	return textedit.text


signal done(text)

onready var textedit: TextEdit = $"%text"
onready var placeholder := $"%placeholder"
onready var sendbutton := $"%SendButton"


func _text_changed() -> void:
	placeholder.visible = len(textedit.text) == 0
	sendbutton.visible = len(textedit.text) != 0


func send(msg := textedit.text) -> void:
	msg = msg.strip_edges()
	if msg:
		textedit.text = ""
		textedit.emit_signal("text_changed")
		emit_signal("done", msg)

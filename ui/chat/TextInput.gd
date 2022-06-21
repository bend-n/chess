extends Control

signal send(message)

onready var textedit := $h/MC/text
onready var placeholder := $h/MC/placeholder


func _on_text_changed() -> void:
	placeholder.visible = len(textedit.text) == 0


func _on_text_send(msg: String) -> void:
	emit_signal("send", msg)


func setup_emojis(_emojis: Dictionary) -> void:
	$h/MC2/EmojiButton._setup(_emojis)

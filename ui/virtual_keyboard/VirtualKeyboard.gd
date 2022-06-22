extends CanvasLayer
class_name VirtualKeyboard

onready var holder = $ForceDown
var text: TextEditor

signal done(text)
signal closed(text)

export(PackedScene) var text_editor


func _ready():
	if !OS.has_touchscreen_ui_hint():
		$ForceDown/Panel/V/KeyHolder.free()  # remove keys if not touchscreen
	text = text_editor.instance()
	$ForceDown/Panel/V.add_child(text)
	$ForceDown/Panel/V.move_child(text, 0)
	text.connect("done", self, "done")


func open(with_text: String = "") -> void:
	text.text = with_text
	var txedit = text.textedit
	txedit.grab_focus()
	txedit.cursor_set_line(txedit.get_line_count() - 1)
	txedit.cursor_set_column(len(txedit.get_line(txedit.get_line_count() - 1)))

	show()


func hide():
	holder.hide()


func show():
	holder.show()


func done(tx := text.text) -> void:
	emit_signal("done", tx)
	hide()


func _on_Close_pressed():
	hide()
	emit_signal("closed", text.text)

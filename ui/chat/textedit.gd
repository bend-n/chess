extends ExpandableTextEdit

signal send(msg)

const auto_complete = [
	"bigsmile",
	"cold",
	"cry",
	"flushed",
	"happy",
	"hmm",
	"huh",
	"kiss",
	"oh",
	"smile",
	"unhappy",
	"upsidedown_smile",
	"weary",
	"what",
	"wink_tongue",
	"wink",
	"wow",
	"zany",
	"..."
]


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			var key_name = OS.get_scancode_string(event.get_scancode_with_modifiers())
			if key_name == "Enter" or key_name == "Kp Enter":
				get_tree().set_input_as_handled()
				if text.length() != 0:
					emit_signal("send", text)
					text = ""
					emit_signal("text_changed")


func _emoji_selected(emoji: String):
	text += emoji
	emit_signal("text_changed")

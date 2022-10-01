extends RichTextLabel

export var color: Color

const vague_error = "[color=#%s][/color] You are unable to use chess engine functionality."
const web_noengine := """[color=#%s][/color] Your browser does not [i]yet[/i] support [url=https://stockfishchess.org/]Stockfish[/url].
     Try  chrome for access to [url=https://stockfishchess.org/]Stockfish[/url]."""
const desktop_noengine := """[color=#%s][/color] [url=https://stockfishchess.org/]Stockfish[/url] is not [i]yet[/i] implemented for desktop.
     Try it on [url=https://bendn.itch.io/chess]web[/url] to use [url=https://stockfishchess.org/]Stockfish[/url]."""


func _ready() -> void:
	yield(get_tree(), "idle_frame")
	if not visible:  # engine exists yay
		return

	connect("meta_clicked", self, "open_url")
	if OS.has_feature("JavaScript"):
		append_bbcode(web_noengine % color.to_html())
	elif OS.has_feature("pc"):
		append_bbcode(desktop_noengine % color.to_html())
	else:
		append_bbcode(vague_error % color.to_html())


func open_url(meta):
	OS.shell_open(str(meta))

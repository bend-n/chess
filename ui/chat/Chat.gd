extends Control
class_name Chat

onready var labels = find_node("labels")
onready var text: TextEdit = find_node("text")
onready var scroller = find_node("scroller")
onready var scrollbar = scroller.get_v_scrollbar()

var tween = Tween.new()
var regexes: Array = [
	[compile("_([^_]+)_"), "[i]$1[/i]"],
	[compile("\\*\\*([^\\*\\*]+)\\*\\*"), "[b]$1[/b]"],
	[compile("\\*([^\\*]+)\\*"), "[i]$1[/i]"],
	[compile("```([^`]+)```"), "[code]$1[/code]"],
	[compile("`([^`]+)`"), "[code]$1[/code]"],
	[compile("~~([^~]+)~~"), "[s]$1[/s]"],
	[compile("#([^#]+)#"), "[rainbow freq=.3 sat=.7]$1[/rainbow]"],
	[compile("%([^%]+)%"), "[shake rate=20 level=25]$1[/shake]"],
	[compile("\\[([^\\]]+)\\]\\(([^\\)]+)\\)"), "[url=$2]$1[/url]"],
	[compile("((res://)?(http(s)?://.)?(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*))"), "[url]$1[/url]"],
]


func server(txt: String) -> void:
	add_label("[b]server[color=#f0e67e]:[/color] " + md2bb(txt))


func _init():
	Globals.chat = self


func _exit_tree():
	Globals.chat = null


func _ready():
	if Globals.network:
		Globals.network.connect("chat", self, "add_label_with")
	add_child(tween)
	server("Welcome!")
	yield(get_tree().create_timer(.4), "timeout")
	server("You can use markdown(sort of)!")


static func compile(src: String) -> RegEx:
	var regex := RegEx.new()
	regex.compile(src)
	return regex


func add_label_with(data):
	var string = "[b]%s[color=#f0e67e]:[/color][/b] %s" % [data.who, data.text]
	add_label(string)


func add_label(bbcode: String, name = "text", size = Vector2(rect_size.x, 0)) -> RichTextLabel:
	var l := RichTextLabel.new()
	l.name = name
	l.rect_min_size = size
	l.bbcode_enabled = true
	l.scroll_active = false
	labels.add_child(l)
	l.connect("meta_clicked", self, "open_url")
	l.bbcode_text = bbcode
	l.fit_content_height = true
	tween.interpolate_property(scrollbar, "value", scrollbar.value, scrollbar.max_value, .5, Tween.TRANS_BOUNCE)
	tween.start()
	return l


func open_url(meta):
	OS.shell_open(meta)


func send(_arg = 0):
	var t = text.get_text().strip_edges()
	if !t:
		return
	t = md2bb(t)
	text.text = ""
	var name_data = SaveLoad.get_data("id").name
	var name = name_data if name_data else "Anonymous"
	name += "(%s)" % ("Spectator" if Globals.spectating else Globals.get_team())
	if Globals.network:
		Globals.network.relay_signal({"text": t, "who": name}, Network.RELAYHEADERS.chat)
	else:
		add_label_with({text = t, who = name})  # for testing


# markdown to bbcode
func md2bb(input: String) -> String:
	for replacement in regexes:
		var result = replacement[0].search(input)
		if result:
			var index = input.find(result.strings[0]) - 1
			var char_before = input[index]
			if not char_before in "\\":  # taboo characters go here
				if replacement[1] == "[url]$1[/url]" and result.strings[3] == "res://":  # url one must avoid recognizing res://
					continue
				input = replacement[0].sub(input, replacement[1], true)
	input = input.replace("\\", "")  # remove escapers
	return input


func err(err: String):
	add_label("[b][color=#ff6347]error:[i] %s" % err)
	text.editable = false

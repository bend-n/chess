extends Control

onready var labels = find_node("labels")
onready var text: TextEdit = find_node("text")
onready var scroller = find_node("scroller")
onready var scrollbar = scroller.get_v_scrollbar()

const server_says = "[b]server[color=#f0e67e]:[/color][/b] "

var tween = Tween.new()
var regexes: Array = [
	[compile("_([^_]+)_"), "[i]$1[/i]"],
	[compile("\\*\\*([^\\*\\*]+)\\*\\*"), "[b]$1[/b]"],
	[compile("\\*([^\\*]+)\\*"), "[i]$1[/i]"],
	[compile("```([^`]+)```"), "[code]$1[/code]"],
	[compile("`([^`]+)`"), "[code]$1[/code]"],
	[compile("~~([^~]+)~~"), "[s]$1[/s]"],
	[compile("#([^#]+)#"), "[rainbow freq=.3 sat=.7]$1[/rainbow]"],
	[compile("%([^%]+)%"), "[shake rate=20 level=25]$1[/shake]"]
]


func _ready():
	if Globals.network:
		Globals.network.connect("chat", self, "add_label_with")
	add_child(tween)
	add_label("%s[b]welcome!" % server_says, "server")
	yield(get_tree().create_timer(.4), "timeout")
	add_label("%s[b]you can use markdown(sort of)!" % server_says)


static func compile(src: String) -> RegEx:
	var regex := RegEx.new()
	regex.compile(src)
	return regex


func add_label_with(data):
	var string = "[b]%s[color=#f0e67e]:[/color][/b] %s" % [data.who, data.text]
	add_label(string)


func add_label(
	bbcode: String, name = "richtextlabel", size = Vector2(rect_size.x, 35)
) -> RichTextLabel:
	var l = RichTextLabel.new()
	l.name = name
	l.rect_min_size = size
	l.bbcode_enabled = true
	l.scroll_active = false
	labels.add_child(l)
	l.connect("meta_clicked", self, "open_url")
	l.bbcode_text = bbcode
	# l.fit_content_height = true
	tween.interpolate_property(
		scrollbar, "value", scrollbar.value, scrollbar.max_value, .5, Tween.TRANS_BOUNCE
	)
	tween.start()
	return l


func open_url(meta):
	OS.shell_open(meta)


func send(_arg = 0):
	var t = text.get_text().strip_edges()
	if !t:
		return
	t = translate_md(t)
	text.text = ""
	var name_data = SaveLoad.get_data("id").name
	var name = name_data if name_data else "Anonymous"
	Globals.network.relay_signal(
		{"text": t, "who": name if name else "Anonymous"}, Network.RELAYHEADERS.chat
	)


# markdown to bbcode
func translate_md(input: String) -> String:
	for replacement in regexes:
		input = replacement[0].sub(input, replacement[1])
	return input


func err(err: String):
	add_label("[b][color=#ff6347]error:[i] %s" % err)
	text.editable = false

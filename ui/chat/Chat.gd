extends Control
class_name Chat

onready var list: MessageList = $v/MessageList
onready var kb = $v/Keyboard
onready var dsk_input: TextEditor = $v/DesktopInput

var regexes := [
	[compile("_([^_]+)_"), "[i]$1[/i]"],
	[compile("\\*\\*([^\\*\\*]+)\\*\\*"), "[b]$1[/b]"],
	[compile("\\*([^\\*]+)\\*"), "[i]$1[/i]"],
	[compile("```([^`]+)```"), "[code]$1[/code]"],
	[compile("`([^`]+)`"), "[code]$1[/code]"],
	[compile("~~([^~]+)~~"), "[s]$1[/s]"],
	[compile("#([^#]+)#"), "[rainbow freq=.3 sat=.7]$1[/rainbow]"],
	[compile("%([^%]+)%"), "[shake rate=20 level=25]$1[/shake]"],
	[compile("\\[([^\\]]+)\\]\\(([^\\)]+)\\)"), "[url=$2]$1[/url]"],
	[compile("([-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*))"), "[url]$1[/url]"],
]
var emoji_replace_regex := compile(":[^:]{1,30}:")

const piece_emoji_path = "res://assets/pieces/cburnett/"
const emoji_path = "res://assets/emojis/"
const emojis := {
	[":cold:"]: emoji_path + "cold.png",
	[":bigsmile:"]: emoji_path + "bigsmile.png",
	[":cry:", ":sad:"]: emoji_path + "cry.png",
	[":happy:"]: emoji_path + "happy.png",
	[":hmm:"]: emoji_path + "hmm.png",
	[":huh:"]: emoji_path + "huh.png",
	[":smile:"]: emoji_path + "smile.png",
	[":unhappy:"]: emoji_path + "unhappy.png",
	[":upsidedown_smile:"]: emoji_path + "upsidedown_smile.png",
	[":weary:"]: emoji_path + "weary.png",
	[":what:"]: emoji_path + "what.png",
	[":wink_tongue:"]: emoji_path + "wink_tongue.png",
	[":wink:"]: emoji_path + "wink.png",
	[":wow:"]: emoji_path + "wow.png",
	[":zany:"]: emoji_path + "zany.png",
	[":...:"]: emoji_path + "3dots.png",
	[":R:", ":rook:"]: piece_emoji_path + "wR.png",
	[":N:", ":knight:"]: piece_emoji_path + "wN.png",
	[":B:", ":bishop:"]: piece_emoji_path + "wB.png",
	[":Q:", ":queen:"]: piece_emoji_path + "wQ.png",
	[":K:", ":king:"]: piece_emoji_path + "wK.png",
	[":P:", ":pawn:"]: piece_emoji_path + "wP.png",
}
var expanded_emojis = {}


# create smokey centered text
func server(txt: String) -> void:
	list.add_label("[center][i][b][color=#a9a9a9]%s[/color][/b][/i][/center]" % md2bb(txt))


func _init():
	Globals.chat = self


func _exit_tree():
	Globals.chat = null


func setup_triggers():
	for trigger_list in emojis:
		for trigger in trigger_list:
			expanded_emojis[trigger] = emojis[trigger_list]


func setup_text_input():
	if OS.has_touchscreen_ui_hint():
		# dsk_input is a little dummy button that just opens the kb and shows text on mobile
		kb.connect("done", self, "send")
		kb.connect("closed", dsk_input, "set_text")
		kb.text.emojibutton._setup(emojis)
		dsk_input.textedit.connect("focus_entered", self, "open_kb")
		print("mobile keyboard setup")
	else:
		kb.free()
		dsk_input.show()
		dsk_input.connect("done", self, "send")

	dsk_input.emojibutton._setup(emojis)


func open_kb():
	kb.open(dsk_input.text)


func _ready():
	setup_triggers()
	setup_text_input()
	PacketHandler.connect("chat", self, "add_label_with")
	server("Welcome!")  # say hello
	yield(get_tree().create_timer(.4), "timeout")
	server("You can use markdown(sort of)!")  # say hello again


static func compile(src: String) -> RegEx:
	var regex := RegEx.new()
	regex.compile(src)
	return regex


func add_label_with(data: Dictionary) -> void:
	var string := "[b]{who}[color=#f0e67e]:[/color][/b] {text}".format(data)
	list.add_label(string)


func send(t: String) -> void:
	t = t.strip_edges()
	if !t:
		return
	t = md2bb(emoji2bb(t))
	var name_data = SaveLoad.get_data("id").name
	var name = name_data if name_data else "Anonymous"
	name += "(%s)" % ("Spectator" if Globals.spectating else Globals.get_team())
	if PacketHandler.connected:
		PacketHandler.relay_signal({"text": t, "who": name}, PacketHandler.RELAYHEADERS.chat)
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
				if replacement[1] == "[url]$1[/url]" and "png" in result.strings[0]:  # url one must avoid recognizing res://
					continue
				input = replacement[0].sub(input, replacement[1], true)
	input = input.replace("\\", "")  # remove escapers
	return input


func emoji2bb(input: String) -> String:
	for i in emoji_replace_regex.search_all(input):
		var emoji = i.strings[0]
		if emoji in expanded_emojis:
			input = input.replace(emoji, "[img=30]%s[/img]" % expanded_emojis[emoji])
	return input

extends Control
class_name Chat

onready var list: MessageList = $v/MessageList
onready var kb = $v/Keyboard
onready var dsk_input: TextEditor = $v/DesktopInput

var regexes := [
	[Utils.compile("_([^_]+)_"), "[i]$1[/i]"],
	[Utils.compile("\\*\\*([^\\*\\*]+)\\*\\*"), "[b]$1[/b]"],
	[Utils.compile("\\*([^\\*]+)\\*"), "[i]$1[/i]"],
	[Utils.compile("```([^`]+)```"), "[code]$1[/code]"],
	[Utils.compile("`([^`]+)`"), "[code]$1[/code]"],
	[Utils.compile("~~([^~]+)~~"), "[s]$1[/s]"],
	[Utils.compile("#([^#]+)#"), "[rainbow freq=.3 sat=.7]$1[/rainbow]"],
	[Utils.compile("%([^%]+)%"), "[shake rate=20 level=25]$1[/shake]"],
	[Utils.compile("\\[([^\\]]+)\\]\\(([^\\)]+)\\)"), "[url=$2]$1[/url]"],
	[
		Utils.compile("([-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*))"),
		"[url]$1[/url]"
	],
]
var emoji_replace_regex: RegEx = Utils.compile(":[^:]{1,30}:")

const piece_emoji_path = "res://assets/pieces/cburnett/"
const emoji_path = "res://assets/emojis/"
const emojis := {
	":grinning:": "😀",
	":smiley:": "😃",
	":smile:": "😄",
	":grin:": "😁",
	[":laughing:", ":satisfied:"]: "😆",
	":sweat_smile:": "😅",
	":joy:": "😂",
	":rofl:": "🤣",
	":blush:": "😊",
	":innocent:": "😇",
	[":slight_smile:", ":slightly_smiling:"]: "🙂",
	[":upside_down:", ":upside_down:"]: "🙃",
	":wink:": "😉",
	":relieved:": "😌",
	":tear_smile:": "🥲",
	":heart_eyes:": "😍",
	":hearty:": "🥰",
	":stuck_out_tongue_winking_eye:": "😜",
	":yum:": "😋",
	":stuck_out_tongue_closed_eyes:": "😝",
	":stuck_out_tongue:": "😛",
	":raised_eyebrow:": "🤨",
	":sunglasses:": "😎",
	":nerd:": "🤓",
	":star_struck:": "🤩",
	":partying:": "🥳",
	":smirk:": "😏",
	":unamused:": "😒",
	":disappointed:": "😞",
	":pensive:": "😔",
	":worried:": "😟",
	":confused:": "😕",
	":frown:": "🙁",
	":persevere:": "😣",
	":confounded:": "😖",
	":tired:": "😫",
	":weary:": "😩",
	":cry:": "😢",
	":sob:": "😭",
	":triumph:": "😤",
	":angry:": "😠",
	":rage:": "😡",
	":no_mouth:": "😶",
	":sleeping:": "😴",
	":cold:": "🥶",
	":neutral:": "😐",
	":expressionless:": "😑",
	":hushed:": "😯",
	":frowning:": "😦",
	":anguished:": "😧",
	":open_mouth:": "😮",
	":astonished:": "😲",
	":dizzy:": "😵",
	":scream:": "😱",
	":fearful:": "😨",
	":cold_sweat:": "😰",
	":disappointed_relieved:": "😥",
	":sweat:": "😓",
	":sleepy:": "😪",
	":devil:": "😈",
	":face_with_rolling_eyes:": "🙄",
	":lying:": "🤥",
	":grimacing:": "😬",
	":zipped_mouth:": "🤐",
	":nauseated:": "🤢",
	":sneezing:": "🤧",
	":mask:": "😷",
	":face_with_thermometer:": "🤒",
	":face_with_head_bandage:": "🤕",
	":smiley_cat:": "😺",
	":smile_cat:": "😸",
	":joy_cat:": "😹",
	":heart_eyes_cat:": "😻",
	":turtle:": "🐢",
	":cat:": "🐈",
	":smirk_cat:": "😼",
	":scream_cat:": "🙀",
	":cat_joy:": "😹",
	":cat_grin:": "😸",
	":crying_cat:": "😿",
	":pouting_cat:": "😾",
}
var expanded_emojis = {}


# create smokey centered text
func server(txt: String) -> void:
	list.add_label("[center][i][b][color=#a9a9a9]%s[/color][/b][/i][/center]" % md2bb(txt))


func _init():
	Globals.chat = self


func _exit_tree():
	Globals.chat = null


func expand_emojis():
	for trigger_list in emojis:
		if typeof(trigger_list) == TYPE_ARRAY:
			for trigger in trigger_list:
				expanded_emojis[trigger] = emojis[trigger_list]
		else:
			expanded_emojis[trigger_list] = emojis[trigger_list]


func setup_text_input():
	if OS.has_touchscreen_ui_hint():
		# dsk_input is a little dummy button that just opens the kb and shows text on mobile
		kb.connect("done", self, "send")
		kb.connect("closed", dsk_input, "set_text")
		kb.text.emojibutton._setup(emojis)
		dsk_input.textedit.connect("focus_entered", self, "open_kb")
		Log.info("Mobile keyboard setup")
	else:
		kb.free()
		dsk_input.show()
		dsk_input.connect("done", self, "send")

	dsk_input.emojibutton._setup(emojis)


func open_kb():
	kb.open(dsk_input.text)


func _ready():
	expand_emojis()
	setup_text_input()
	PacketHandler.connect("chat", self, "add_label_with")
	server("Welcome!")  # say hello
	yield(get_tree().create_timer(.4), "timeout")
	server("You can use markdown(sort of)!")  # say hello again


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
	name += "(%s)" % ("Spectator" if Globals.spectating else Globals.team)
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
			input = input.replace(emoji, "%s" % expanded_emojis[emoji])
	return input

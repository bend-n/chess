extends PanelContainer
class_name MessageList

onready var labels = find_node("labels")
onready var scroller = find_node("scroller")
onready var scrollbar = scroller.get_v_scrollbar()

var tween := Tween.new()


func _ready():
	add_child(tween)


func add_label(bbcode: String):
	var l := RichTextLabel.new()
	l.bbcode_enabled = true
	l.scroll_active = false
	labels.add_child(l)
	l.connect("meta_clicked", self, "open_url")
	l.bbcode_text = bbcode
	l.fit_content_height = true
	tween.interpolate_property(scrollbar, "value", scrollbar.value, scrollbar.max_value, .5, Tween.TRANS_BOUNCE)
	tween.start()


func open_url(meta):
	OS.shell_open(str(meta))

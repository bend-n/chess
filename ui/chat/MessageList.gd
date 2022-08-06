extends PanelContainer
class_name MessageList

onready var labels = find_node("labels")
onready var scroller = find_node("scroller")
onready var scrollbar = scroller.get_v_scrollbar()


func add_label(bbcode: String):
	var l := RichTextLabel.new()
	l.bbcode_enabled = true
	l.scroll_active = false
	labels.add_child(l)
	l.connect("meta_clicked", self, "open_url")
	l.bbcode_text = bbcode
	l.fit_content_height = true
	yield(get_tree(), "idle_frame")
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(scrollbar, "value", scrollbar.max_value, .5)


func open_url(meta):
	OS.shell_open(str(meta))

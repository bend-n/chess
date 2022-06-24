extends Button

export(float) var scale_normal := 0.8
export(float) var scale_hover := 1.0
var cur_scale := scale_normal

export(float) var saturation_normal := 0.0
export(float) var saturation_hover := 1.0
var cur_saturation := saturation_normal

export(float) var weight := 0.35

export(Vector2) var offset = Vector2.ZERO

var emojis := {}

var focused := false

signal emoji_selected(emoji)

onready var emojimenu: GridMenu = $Popup/EmojiMenu
onready var popup: PopupPanel = $Popup
var font: DynamicFont = load("res://ui/chat/emoji_button_font.tres")
onready var font_size = font.size


func change_icon():
	if emojis:
		text = emojis.values()[randi() % len(emojis)]


func _ready():
	scale()
	set_process(false)


func _setup(_emojis: Dictionary):
	emojis = _emojis
	change_icon()
	for key in emojis.keys():
		emojimenu.add_text_item(emojis[key], arr2tooltip(key), Vector2(40, 40))


func arr2tooltip(arr) -> String:
	if typeof(arr) == TYPE_ARRAY:
		var string = ""
		for i in arr:
			string += i + " "
		return string
	return arr


func _focused(q: bool):
	focused = q
	if q:
		change_icon()
		set_process(true)


func _process(_delta: float) -> void:
	if focused:
		cur_scale = lerp(cur_scale, scale_hover, weight)
		cur_saturation = lerp(cur_saturation, saturation_hover, weight)
	else:
		cur_scale = lerp(cur_scale, scale_normal, weight)
		cur_saturation = lerp(cur_saturation, saturation_normal, weight)
		if is_equal_approx(cur_scale, scale_normal):
			set_process(false)

	scale()
	material.set_shader_param("saturation", cur_saturation)


func scale():
	font.size = cur_scale * font_size


func _pressed() -> void:
	popup.popup()
	emojimenu.open()
	yield(get_tree(), "idle_frame")
	popup.rect_global_position = rect_global_position + offset


func _on_EmojiMenu_pressed(index: int):
	emit_signal(
		"emoji_selected",
		emojis.keys()[index] if typeof(emojis.keys()[index]) == TYPE_STRING else emojis.keys()[index][0]
	)
	popup.hide()

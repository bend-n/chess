extends Node2D

var refs := []  # = [[ node : object, variable : string, (code : string) ]]
var style: StyleBox = load("res://ui/theme/transblack.tres")
var font: Font = load("res://ui/ubuntu-bold.tres")
var debug := false  # in debug mode or not
var timer := Timer.new()
var expr := Expression.new()

const offset := Vector2(10, 10)
const vertical := 15


static func is_debug() -> bool:
	var args := Utils.get_args()
	if "debug" in args:
		return Utils.str_bool(args.debug)
	return OS.is_debug_build()


func _ready() -> void:
	z_index = 5  # put on top
	add_child(timer)
	timer.connect("timeout", self, "update")
	timer.start(.1)  # only redraw every .1 seconds
	font = font.duplicate()
	font.size = vertical * 0.8
	debug = is_debug()
	visible = debug


func monitor(node: Object, what: String, code := "") -> void:  # code doesnt really work well with ternarys
	refs.append([node, what, code] if code else [node, what])
	calculate_size()


func calculate_size() -> Rect2:
	var xminsize := 0.0
	for set in refs:  # find the chonkiest text
		var tmp := font.get_string_size(get_string(set)).x
		xminsize = tmp if tmp > xminsize else xminsize
	return Rect2(Vector2.ZERO, Vector2(xminsize + offset.x, (refs.size()) * vertical) + offset)


func update() -> void:
	timer.start(.1)
	.update()


func _draw() -> void:
	if !debug:
		return
	draw_style_box(style, calculate_size())
	var i = len(refs)
	while i > 0:
		i -= 1
		var pos := Vector2(offset.x, (i + 1) * vertical)
		draw_string(font, pos, get_string(refs[i]))


func get_string(set: Array) -> String:
	var node: Object = set[0]
	if !is_instance_valid(node):
		refs.erase(set)
		return "invalid!"
	var what: String = set[1]
	var gotten = node.get(what)
	var val: String = str(gotten) if typeof(gotten) != TYPE_DICTIONARY else to_json(gotten)
	if len(set) == 3:
		var err := expr.parse(set[2])
		if err != OK:
			Log.err(expr.get_error_text())
			return ""
		val = str(expr.execute([], node, true))
	return "%s: %s" % [what, val]

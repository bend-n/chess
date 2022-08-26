extends Control
class_name Piece

var position: String
var color: String
var type: String

onready var sprite = $Sprite
onready var frame = $"%Frame"
onready var background = $"%Background"
onready var check = $"%Check"
onready var anim = $AnimationPlayer
onready var rotate = $RotatePlayer

# for pawn promotion
signal promotion_decided(promote_to)

var b


func size() -> void:  # size the control
	rect_size = b.piece_size
	rect_pivot_offset = rect_size / 2
	rect_position = Chess.algebraic2vec(position) * b.piece_size
	sprite.flip_v = b.flipped
	sprite.flip_h = b.flipped


func _ready():
	load_texture()
	background.color = b.overlay_color

	if type == Chess.KING:
		Events.connect("turn_over", self, "check_in_check")

	size()
	Events.connect("turn_over", self, "turn_over")


func turn_over():
	if b.is_my_turn():
		background.color = b.overlay_color
	else:
		background.color = b.premove_color


func check_in_check():
	check.visible = b.chess.__king_attacked(color)


func _pressed(p: String) -> void:
	emit_signal("promotion_decided", p.to_lower())


func open_promotion_previews(darken: ColorRect):
	darken.show()
	var popup = get_node_or_null("previews")
	if not popup:
		popup = PopupPanel.new()
		popup.name = "previews"
		popup.popup_exclusive = true
		popup.add_stylebox_override("panel", StyleBoxEmpty.new())
		var previews := VBoxContainer.new()
		previews.name = "previews"
		previews.add_constant_override("separation", 0)
		popup.add_child(previews)
		add_child(popup)
		for p in "QNRB":
			var newsprite := PromotionPreview.new()
			newsprite.hint_tooltip = p
			var img_path = "res://assets/pieces/%s/%s%s.png" % [Globals.piece_set, color, p]
			newsprite.texture_normal = load(img_path)
			newsprite.name = p
			newsprite.connect("pressed", self, "_pressed", [p])
			previews.add_child(newsprite)

	var rect = Rect2(rect_global_position, Vector2(b.piece_size.x, b.piece_size.y * 4))
	popup.popup(rect)
	yield(self, "promotion_decided")
	darken.hide()
	popup.hide()


func load_texture(path := "res://assets/pieces/%s/%s%s.png" % [Globals.piece_set, color, type.to_upper()]) -> void:
	sprite.texture = load(path)


func set_zindex(zindex: int, obj: CanvasItem = self) -> void:  # used by the animation player
	VisualServer.canvas_item_set_z_index(obj.get_canvas_item(), zindex)


# returns self for function chaining
func move(to: String, synchronized := false) -> Piece:
	if synchronized:
		yield(get_tree(), "idle_frame")

	name = "%s-%s" % [type, to]
	b.set_piece(position, null)
	b.set_piece(to, self)
	var go_to = Chess.algebraic2vec(to)
	var signresult := int(sign(Chess.algebraic2vec(position).x - go_to.x))

	if signresult == 1:
		rotate.play("Right")
	elif signresult == -1:
		rotate.play("Left")
	anim.play("Move")
	position = to
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, @"rect_position", go_to * b.piece_size, 0.3)
	if synchronized:
		yield(tween, "finished")
	return self


func took() -> void:
	b.set_piece(position, null)
	frame.hide()
	anim.play("Took")

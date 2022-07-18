extends Control
class_name Piece

var position := ""
var color := "w"
var type := ""
var tween := Tween.new()

onready var sprite = $Sprite
onready var frame = $Sprite/Frame
onready var background = $ColorRect
onready var anim = $AnimationPlayer
onready var rotate = $RotatePlayer

# for pawn promotion
var previews: VBoxContainer = null
var popup: PopupPanel = null
signal promotion_decided
var promote_to := ""


func size() -> void:  # size the control
	rect_min_size = Globals.grid.piece_size
	rect_position = Chess.algebraic2vec(position) * Globals.grid.piece_size
	rect_pivot_offset = Globals.grid.piece_size / 2


func _ready():
	add_child(tween)
	load_texture()
	size()
	frame.modulate = Globals.grid.overlay_color
	background.color = Globals.grid.overlay_color

	sprite.flip_v = Globals.grid.flipped
	sprite.flip_h = Globals.grid.flipped

	if type == Chess.PAWN:
		popup = PopupPanel.new()
		popup.popup_exclusive = true
		popup.add_stylebox_override("panel", StyleBoxEmpty.new())
		previews = VBoxContainer.new()
		previews.add_constant_override("separation", 0)
		popup.add_child(previews)
		add_child(popup)
		for p in "qnrb":
			var newsprite := PromotionPreview.new()
			newsprite.hint_tooltip = p
			var img_path = "res://assets/pieces/%s/%s%s.png" % [Globals.piece_set, color.to_lower(), p.to_upper()]
			newsprite.texture_normal = load(img_path)
			newsprite.name = p
			newsprite.connect("pressed", self, "_pressed", [p])
			previews.add_child(newsprite)


func _pressed(p: String) -> void:
	popup.hide()
	$"../../Darken".hide()
	promote_to = p
	emit_signal("promotion_decided")


func open_promotion_previews():
	popup.set_as_minsize()
	var rect := popup.get_global_rect()
	rect.position = rect_global_position
	popup.popup(rect)
	$"../../Darken".show()


func load_texture(path := "res://assets/pieces/%s/%s%s.png" % [Globals.piece_set, color, type.to_upper()]) -> void:
	sprite.texture = load(path)


func set_zindex(zindex: int, obj: CanvasItem = self) -> void:  # used by the animation player
	VisualServer.canvas_item_set_z_index(obj.get_canvas_item(), zindex)


# returns self for function chaining
func move(to: String) -> Piece:
	Globals.grid.set_piece(position, null)
	Globals.grid.set_piece(to, self)
	var go_to = Chess.algebraic2vec(to)
	tween.interpolate_property(
		self, "rect_position", rect_position, go_to * Globals.grid.piece_size, 0.3, Tween.TRANS_BACK
	)
	var signresult := int(sign(Chess.algebraic2vec(position).x - go_to.x))
	if signresult == 1:
		rotate.play("Right")
	elif signresult == -1:
		rotate.play("Left")
	anim.play("Move")
	tween.start()
	position = to
	return self


func took() -> void:
	Globals.grid.set_piece(position, null)
	frame.hide()
	anim.play("Took")

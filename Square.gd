extends ColorRect

var realname = "Square"
var real_position = Vector2()

onready var area = $Squarea
onready var areacollisionshape = $Squarea/CollisionShape2D

signal clicked(real_position)


func _ready():
	areacollisionshape.global_position += Globals.piece_size / 2
	areacollisionshape.shape.extents = Vector2(rect_size.x / 2, rect_size.y / 2)


func _on_Squarea_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		emit_signal("clicked", real_position)

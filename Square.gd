extends ColorRect

var real_position = Vector2()
var algebraic_string = ""
var circle_on = false

onready var area = $Squarea
onready var areacollisionshape = $Squarea/CollisionShape2D
onready var circle = $Circle

signal clicked(real_position)


func _ready():
	circle.position = Globals.grid.piece_size / 2
	circle.modulate = Globals.grid.overlay_color
	circle.visible = false
	areacollisionshape.global_position += Globals.grid.piece_size / 2
	areacollisionshape.shape.extents = Vector2(rect_size.x / 2, rect_size.y / 2)
	algebraic_string = Utils.calculate_algebraic_position(real_position)


func _on_Squarea_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		emit_signal("clicked", real_position)


func get_string():
	return algebraic_string


func set_circle(boolean: bool, real = true):
	circle_on = boolean
	if real:
		circle.visible = boolean

extends ColorRect

var real_position := Vector2()
var algebraic_string := ""
var circle_on := false

onready var area := $Squarea
onready var areacollisionshape := $Squarea/CollisionShape2D
onready var circle := $Circle

signal clicked


func _ready() -> void:
	circle.position = Globals.grid.piece_size / 2
	circle.material.set_shader_param("color", Globals.grid.overlay_color)
	circle.visible = false
	areacollisionshape.global_position += Globals.grid.piece_size / 2
	areacollisionshape.shape.extents = Vector2(rect_size.x / 2, rect_size.y / 2)
	algebraic_string = Utils.calculate_algebraic_position(real_position)


func _on_Squarea_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("click"):
		emit_signal("clicked", real_position)


func get_string() -> String:
	return algebraic_string


func set_circle(boolean: bool, real = true) -> void:
	circle_on = boolean
	if real:
		circle.visible = boolean

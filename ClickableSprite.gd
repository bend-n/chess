extends Node2D

signal clicked

var c = 0

onready var sprite = $Sprite


func _ready():
	$Area2D/CollisionShape2D.shape.extents = Globals.grid.piece_size / 2


func _on_Area2D_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int):
	if visible and Input.is_action_just_released("click"):
		c += 1
		if c >= 1:
			emit_signal("clicked", self)


func _on_Area2D_mouse_entered():
	sprite.scale = Vector2(1, 1)


func _on_Area2D_mouse_exited():
	sprite.scale = Vector2(1.2, 1.2)

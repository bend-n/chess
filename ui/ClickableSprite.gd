extends Node2D

signal clicked

onready var sprite := $Sprite


func _ready() -> void:
	if get_parent() != get_viewport():
		$Area2D/CollisionShape2D.shape.extents = Globals.grid.piece_size / 2


func _on_Area2D_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if visible and Input.is_action_just_released("click"):
		emit_signal("clicked")


func _on_Area2D_mouse_entered() -> void:
	sprite.scale = Vector2(1.3, 1.3)


func _on_Area2D_mouse_exited() -> void:
	sprite.scale = Vector2(.9, .9)

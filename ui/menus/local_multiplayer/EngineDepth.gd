extends HBoxContainer

signal depth_changed(new_depth)

var depth: int setget set_depth

onready var depth_label: Label = $"%CurrentDepthLabel"


func _ready() -> void:
	set_depth($"%DepthSlider".value)


func set_depth(new_depth: int) -> void:
	emit_signal("depth_changed", new_depth)
	depth_label.text = str(new_depth)
	depth = new_depth


func _slid(value: float) -> void:
	set_depth(value)

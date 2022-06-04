extends Control

onready var status: StatusLabel = $Holder/SidebarRight/VBox/Status


func set_status(text: String, length := 5) -> void:
	status.set_text(text, length)


func get_board() -> Node:
	return $Holder/middle/Board

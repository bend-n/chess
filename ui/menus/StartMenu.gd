extends Control


func _ready() -> void:
	if OS.has_feature("HTML5"):
		find_node("quit").queue_free()


func _on_quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

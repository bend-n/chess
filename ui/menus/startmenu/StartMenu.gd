extends Control


func _ready() -> void:
	if OS.has_feature("web"):
		get_node("% exit").queue_free()


func _on_quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)

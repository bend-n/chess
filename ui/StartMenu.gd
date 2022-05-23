extends Control

const world = preload("res://Board.tscn")

onready var settings := $Darken/Settings


func _ready() -> void:
	if OS.has_feature("HTML5"):
		find_node("quit").queue_free()


func _on_local_pressed() -> void:
	get_tree().change_scene_to(world)


func _on_quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_settings_pressed() -> void:
	settings.toggle(true)


func _on_multiplayer_pressed() -> void:
	get_tree().change_scene("res://ui/Lobby.tscn")

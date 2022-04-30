extends Control

const world = preload("res://World.tscn")

onready var settings = $Settings


func _on_local_pressed():
	get_tree().change_scene_to(world)


func _on_quit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	settings.toggle(true)

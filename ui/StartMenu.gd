extends Control

const world = preload("res://World.tscn")

export(float) var timer_length := 0.0

export(Array, Color) var nice_colors

onready var settings := $ColorRect/Settings
onready var colorrect := $ColorRect
onready var tween := $Tween
onready var timer := $Timer
onready var lobby := $ColorRect/Lobby


func _ready() -> void:
	randomize()
	colorrect.color = nice_colors[randi() % nice_colors.size()]
	timer.start(timer_length)
	_on_Timer_timeout()


func rand(clr) -> float:
	return clamp(clr + rand_range(0, .1) if randi() % 2 else clr - rand_range(0, .1), 0, 1)


func _on_local_pressed() -> void:
	get_tree().change_scene_to(world)


func _on_quit_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_settings_pressed() -> void:
	settings.toggle(true)


func _on_Timer_timeout() -> void:
	var clr = nice_colors[randi() % nice_colors.size()]
	clr.r = rand(clr.r)
	clr.b = rand(clr.b)
	clr.g = rand(clr.g)
	tween.interpolate_property(colorrect, "color", colorrect.color, clr, timer_length, Tween.TRANS_ELASTIC)
	tween.start()
	timer.start(timer_length)


func _on_multiplayer_pressed() -> void:
	lobby.toggle(true)

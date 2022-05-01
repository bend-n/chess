extends Control

const world = preload("res://World.tscn")

export(float) var timer_length := 0.0

onready var settings := $ColorRect/Settings
onready var colorrect := $ColorRect
onready var tween := $Tween
onready var timer := $Timer


func _on_local_pressed():
	get_tree().change_scene_to(world)


func _ready():
	randomize()
	timer.start(timer_length)
	_on_Timer_timeout()


func _on_quit_pressed():
	get_tree().quit()


func _on_settings_pressed():
	settings.toggle(true)


func _on_Timer_timeout():
	tween.interpolate_property(
		colorrect,
		"color",
		colorrect.color,
		Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1)),
		timer_length,
		Tween.TRANS_ELASTIC,
		Tween.EASE_IN_OUT
	)
	tween.start()
	timer.start(timer_length)

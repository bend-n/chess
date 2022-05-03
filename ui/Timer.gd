extends Node

var enabled := false
var time_elapsed := 0.0

var count := 0

onready var whitelabel := $"../WhiteTime"
onready var blacklabel := $"../BlackTime"


func _ready() -> void:
	whitelabel.time = 300
	blacklabel.time = 300
	Events.connect("turn_over", self, "turn_over")


func _process(delta) -> void:
	if !enabled:
		return
	if Globals.turn:
		if !whitelabel.set_time(whitelabel.time - delta):
			enabled = false
	else:
		if !blacklabel.set_time(blacklabel.time - delta):
			enabled = false


func turn_over() -> void:
	time_elapsed = 0.0
	count += 1
	enabled = count >= 2

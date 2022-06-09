extends Node

export(NodePath) var blacklabel
export(NodePath) var whitelabel
onready var labels = [get_node(blacklabel), get_node(whitelabel)]

var turn_time := 0.0


func _process(delta):
	# int of false is 0 and true is 1
	turn_time += delta
	labels[int(Globals.turn)].tick()


func _move_decided():
	prints("turn took", turn_time)
	turn_time = 0.0


func _ready():
	Globals.grid.connect("move_decided", self, "_move_decided")

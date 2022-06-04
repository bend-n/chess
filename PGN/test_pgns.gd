extends VBoxContainer

export(PoolStringArray) var pgns = []

var in_sim = false


func _ready():
	if !Debug.debug:
		queue_free()


func _load(i: int):
	in_sim = true
	var boar = load("res://Board.tscn").instance()
	get_tree().get_root().add_child(boar)
	boar.get_node("Grid").play_pgn(pgns[i])
	get_parent().hide()


func _input(_event):
	if Input.is_action_pressed("ui_cancel") and in_sim:
		in_sim = false
		get_node("/root/Board").queue_free()
		get_parent().show()
		Globals.reset_vars()

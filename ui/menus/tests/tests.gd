extends VBoxContainer

export(PoolStringArray) var pgns

var in_sim = false


func _ready():
	if !Debug.debug:
		queue_free()


func _load(i: int):
	PacketHandler.load_pgn(pgns[i])
	in_sim = true


func _input(_event):
	if Input.is_action_pressed("ui_cancel") and in_sim:
		in_sim = false
		PacketHandler.go_back("", true)
		get_node("/root/Game").queue_free()
		get_parent().show()
		Globals.reset_vars()


func _on_test_chat_pressed():
	get_tree().change_scene_to(preload("res://ui/chat/Chat.tscn"))

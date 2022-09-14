extends Control
class_name Lobby

onready var address: LineEdit = $"%Address"
onready var buttons := $"%buttons"
onready var status_ok := $"%StatusOK"
onready var status_fail := $"%StatusFail"
onready var hostbutton := $"%HostButton"
onready var gameconfig := $"%GameConfig"


func toggle(onoff: bool) -> void:
	get_parent().get_parent().visible = onoff


func _ready() -> void:
	PacketHandler.lobby = self
	PacketHandler.connect("hosting", $"%stophost", "set_visible")
	PacketHandler.connect("connection_established", self, "reset")
	gameconfig.connect("back", self, "reset")
	if !Utils.internet:
		set_status("no internet", false)
		set_buttons(false)


func reset():
	set_status("", true)
	set_buttons(true)


func host(color: bool, moves: PoolStringArray) -> void:
	PacketHandler.host_game(PacketHandler.game_code, color, moves)


func focus():
	get_parent().current_tab = get_parent().get_children().find(self)


func set_status(text: String, isok: bool) -> void:  # Simple way to show status.
	if isok:
		status_ok.text = text
		status_fail.text = ""
	else:
		status_ok.text = ("")
		status_fail.text = (text)
	status_ok.visible = len(status_ok.text) > 0
	status_fail.visible = len(status_fail.text) > 0


func set_buttons(enabled := true) -> void:
	for c in buttons.get_children():
		c.disabled = !enabled
	address.editable = enabled


func _on_join_pressed() -> void:
	if validate_text():
		set_buttons(false)
		PacketHandler.join_game()
	else:
		set_status("Invalid game code", false)


func _on_HostButton_pressed() -> void:
	if gameconfig.visible:
		if not validate_text():
			set_status("Invalid game code", false)
			return
		gameconfig.hide()
		host(gameconfig.color, gameconfig.moves)
		set_buttons(false)
		return
	if validate_text():
		for c in buttons.get_children().slice(0, 1):
			c.disabled = true
		gameconfig.show()
	else:
		set_status("Invalid game code", false)


func validate_text(text := address.get_text()) -> String:
	var pos := address.caret_position
	text = clean_text(text)
	address.text = text
	address.caret_position = pos
	PacketHandler.game_code = text
	return text


func clean_text(text: String) -> String:
	text = text.strip_edges()
	return text.replace(" ", "_")


func _on_Address_text_entered(new_text: String) -> void:
	validate_text(new_text)


func _on_spectate_pressed():
	if validate_text():
		set_buttons(false)
		PacketHandler.spectate()
	else:
		set_status("Invalid address", false)


func _on_stophost_pressed() -> void:
	PacketHandler.return()
	reset()

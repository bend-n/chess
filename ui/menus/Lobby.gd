extends Control
class_name Lobby

onready var address: LineEdit = find_node("Address")
onready var buttons := find_node("buttons")
onready var status_ok := find_node("StatusOK")
onready var status_fail := find_node("StatusFail")


func toggle(onoff: bool) -> void:
	get_parent().visible = onoff


func _ready() -> void:
	PacketHandler.lobby = self
	PacketHandler.connect("hosting", find_node("stophost"), "set_visible")
	if !Utils.internet:
		set_status("no internet", false)
		set_buttons(false)


func set_status(text: String, isok: bool) -> void:  # Simple way to show status.
	if isok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)
	status_ok.visible = len(status_ok.text) > 0
	status_fail.visible = len(status_fail.text) > 0


func set_buttons(enabled := true) -> void:
	for c in buttons.get_children():
		c.disabled = !enabled
	address.editable = enabled


func _on_join_pressed() -> void:
	if validate_text():
		set_buttons(false)
		Globals.network.join_game()
	else:
		set_status("Invalid address", false)


func _on_HostButton_pressed() -> void:
	if validate_text():
		set_buttons(false)
		Globals.network.host_game()
	else:
		set_status("Invalid address", false)


func validate_text(text := address.get_text()) -> String:
	var pos := address.caret_position
	text = text.strip_edges()
	text = text.replace(" ", "_")
	address.text = text
	address.caret_position = pos
	Globals.network.game_code = text
	return text


func _on_Address_text_entered(new_text: String) -> void:
	validate_text(new_text)


func _on_spectate_pressed():
	if validate_text():
		set_buttons(false)
		Globals.network.spectate()
	else:
		set_status("Invalid address", false)


func _on_tabs_tab_changed(tab: int):
	if self != get_parent().get_children()[tab]:
		PacketHandler.return()


func _on_stophost_pressed() -> void:
	PacketHandler.return()

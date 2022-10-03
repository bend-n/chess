extends Control
class_name GameUI

onready var status: StatusLabel = find_node("Status")
onready var chat: Chat = find_node("Chat")
onready var sidebar := $"%Sidebar"
onready var panels := [
	sidebar.whitepanel,
	sidebar.blackpanel,
]


func _ready() -> void:
	PacketHandler.connect("info_recieved", self, "_spectate_info" if Globals.spectating else "_on_info")
	Events.connect("game_over", self, "_game_over")
	if Globals.local:
		get_tree().call_group("freeinlocalmultiplayer", "queue_free")
		get_tree().call_group("showiflocalmultiplayer", "show")


func _game_over(_why: String) -> void:
	get_tree().call_group("showongameover", "show")
	get_tree().call_group("hideongameover", "hide")
	if not Globals.local:
		get_tree().call_group("hideongameoverifnolocalmultiplayer", "hide")


func set_status(text: String, length := 5) -> void:
	status.set_text(text, length)


func get_board() -> Control:
	return $"%Board" as Control


func _spectate_info(info: Dictionary) -> void:
	set_panel(panels[0], info.white.name, info.white.country)
	set_panel(panels[1], info.black.name, info.black.country)


func _on_info(info: Dictionary) -> void:
	var enemy_int := int(Globals.grid.team == "w")
	set_panel(panels[enemy_int], info.name, info.country)  # enemy panel
	set_panel(panels[abs(enemy_int - 1)], Creds.get("name"), Creds.get("country"))  # own panel


func set_panel(pnl: UserPanel, name: String, country: String) -> void:
	pnl.set_name(name if name else "Anonymous")
	pnl.set_flag(country)


func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and event.scancode == KEY_Z and not Globals.local:
		chat.visible = !chat.visible

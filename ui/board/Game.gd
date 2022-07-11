extends Control

onready var status: StatusLabel = find_node("Status")
onready var sidebar := $Holder/SidebarRight
onready var panels := [
	sidebar.whitepanel,
	sidebar.blackpanel,
]


func _ready() -> void:
	PacketHandler.connect("info_recieved", self, "_spectate_info" if Globals.spectating else "_on_info")


func set_status(text: String, length := 5) -> void:
	status.set_text(text, length)


func get_board() -> Node:
	return $Holder/middle/Board


func _spectate_info(info: Dictionary) -> void:
	var whitepnl: UserPanel = panels[0]
	set_panel(whitepnl, info.white.name, info.white.country)
	var blackpnl: UserPanel = panels[1]
	set_panel(blackpnl, info.black.name, info.black.country)


func _on_info(info: Dictionary) -> void:
	var enemy_int := int(Globals.team == "w")
	set_panel(panels[enemy_int], info.name, info.country)  # enemy panel
	set_panel(panels[abs(enemy_int - 1)], Creds.get("name"), Creds.get("country"))  # own panel


func set_panel(pnl, name, country) -> void:
	pnl.set_name(name if name else "Anonymous")
	pnl.set_flag(country)

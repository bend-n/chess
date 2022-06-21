extends Control

onready var status: StatusLabel = find_node("Status")
onready var sidebar := $Holder/SidebarRight
onready var panels := [
	sidebar.blackpanel,
	sidebar.whitepanel,
]


func _ready() -> void:
	if PacketHandler:
		PacketHandler.connect("info_recieved", self, "_spectate_info" if Globals.spectating else "_on_info")


func set_status(text: String, length := 5) -> void:
	status.set_text(text, length)


func get_board() -> Node:
	return $Holder/middle/Board


func _spectate_info(info: Dictionary) -> void:
	var whitepnl = panels[Globals.WHITE]
	set_panel(whitepnl, info.white.name, info.white.country)
	var blackpnl = panels[Globals.BLACK]  #black
	set_panel(blackpnl, info.black.name, info.black.country)


func _on_info(info: Dictionary) -> void:
	set_panel(panels[int(!Globals.team)], info.name, info.country)  # enemy panel
	set_panel(panels[int(Globals.team)], SaveLoad.get_data("id").name, SaveLoad.get_data("id").country)  # own panel


func set_panel(pnl, name, country) -> void:
	pnl.set_name(name if name else "Anonymous")
	pnl.set_flag(country)

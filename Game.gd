extends Control

onready var status: StatusLabel = find_node("Status")
onready var sidebar = $Holder/SidebarRight
onready var panels = [
	sidebar.blackpanel,
	sidebar.whitepanel,
]


func _ready():
	if Globals.network:
		Globals.network.connect("info_recieved", self, "_on_info")


func set_status(text: String, length := 5) -> void:
	status.set_text(text, length)


func get_board() -> Node:
	return $Holder/middle/Board


func _on_info(info: Dictionary):
	var pnl = panels[int(!Globals.team)]
	pnl.set_name(info.name if info.name else "Anonymous")
	pnl.set_flag(info.country)

	# set my own panel
	pnl = panels[int(Globals.team)]
	var name = SaveLoad.get_data("id").name
	pnl.set_name(name if name else "Anonymous")
	pnl.set_flag(SaveLoad.get_data("id").country)

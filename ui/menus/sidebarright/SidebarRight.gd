extends ColorRect

onready var whitepanel = find_node("WhitePanel")
onready var blackpanel = find_node("BlackPanel")
export(NodePath) onready var panel_holder = get_node(panel_holder)


func flip_panels():
	var black_to = panel_holder.get_children().find(whitepanel)
	var white_to = panel_holder.get_children().find(blackpanel)
	panel_holder.move_child(blackpanel, black_to)
	panel_holder.move_child(whitepanel, white_to)

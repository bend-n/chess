extends Label


func _ready():
	Events.connect("set_signed_in", self, "update_vis")


func update_vis(newvis):
	visible = !newvis

extends Label
class_name VersionLabel


func _ready():
	text = "chess " + Utils.get_version()

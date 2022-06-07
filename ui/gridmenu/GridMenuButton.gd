extends Button
class_name GridMenuButton

onready var popup: Popup = $Popup
onready var gridmenu: GridMenu = $Popup/GridMenu

signal selected(index)

var selected := 0 setget set_selected
var items := []


func add_item(icon, tooltip := "", size := Vector2(40, 30)):
	items.append(icon)
	gridmenu.add_item(icon, tooltip, size)


func _on_GridMenu_pressed(index: int):
	set_selected(index)
	emit_signal("selected", index)
	popup.hide()


func set_selected(index: int):
	selected = index
	icon = items[index]


func _pressed() -> void:
	popup.rect_size = Vector2.ZERO
	var rect := popup.get_global_rect()
	rect.position = rect_global_position - Vector2(50, 50)
	popup.popup(rect)
	gridmenu.open()

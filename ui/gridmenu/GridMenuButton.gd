extends Button
class_name GridMenuButton

onready var popup: Popup = $Popup
onready var gridmenu: GridMenu = $Popup/GridMenu

signal selected(index)

export(Vector2) var offset = Vector2(50, -50)

onready var txt = text

var selected := 0 setget set_selected
var items := []


func add_text_item(text: String, tooltip := "", size := Vector2(40, 30)) -> Button:
	items.append(text)
	return gridmenu.add_text_item(text, tooltip, size)


func add_icon_item(icon: Texture, tooltip := "", size := Vector2(40, 30)) -> BarTextureButton:
	items.append(icon)
	return gridmenu.add_icon_item(icon, tooltip, size)


func _on_GridMenu_pressed(index: int):
	set_selected(index)
	emit_signal("selected", index)
	popup.hide()


func set_selected(index: int):
	selected = index
	if typeof(items[index]) == TYPE_OBJECT:
		icon = items[index]
	else:
		text = items[index] + txt


func _pressed() -> void:
	gridmenu.open()
	popup.popup()
	yield(get_tree(), "idle_frame")
	popup.rect_global_position = rect_global_position + offset

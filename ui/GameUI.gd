extends CanvasLayer

onready var status: StatusLabel = $Holder/Back/VBox/Status


func set_status(text: String, length := 5) -> void:
	status.set_text(text, length)

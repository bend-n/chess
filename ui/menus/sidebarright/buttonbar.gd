extends Control


func _ready():
	if Globals.grid.local:
		for c in [$FlipButton, $DrawButton, $ResignButton]:
			c.queue_free()

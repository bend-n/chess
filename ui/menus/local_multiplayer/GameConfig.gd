extends GameConfig

enum { HUMAN, ENGINE }

var players: PoolIntArray = [
	HUMAN,
	HUMAN,
]
var depth: int


func _player_selected(index: int, player: int) -> void:
	players[player - 1] = index


func _ready() -> void:
	get_tree().call_group("freeifnoengine", "hide")
	var loader = StockfishLoader.new()
	if loader.is_supported():
		get_tree().call_group("freeifnoengine", "show")
		return
	get_tree().call_group("freeifnoengine", "queue_free")
	get_tree().call_group("showifnoengine", "show")


func _depth_changed(new_depth: int) -> void:
	depth = new_depth

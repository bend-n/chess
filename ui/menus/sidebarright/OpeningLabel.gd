extends Label
class_name OpeningLabel

var http_request := HTTPRequest.new()

var url := "https://explorer.lichess.ovh/masters?topGames=0&moves=2&fen=%s"
var current_req := ""


func _ready():
	add_child(http_request)
	Events.connect("turn_over", self, "update_opening")
	Globals.grid.connect("load_pgn", self, "update_opening")
	Globals.grid.connect("clear_pgn", self, "update_opening")
	Globals.grid.connect("remove_last", self, "update_opening")
	http_request.connect("request_completed", self, "_request_completed")


func update_opening(_var := null) -> void:
	if Utils.internet:
		var fen := Globals.grid.chess.fen()
		if fen != Globals.grid.chess.DEFAULT_POSITION && fen != current_req:
			if current_req:
				http_request.cancel_request()
			text = ""
			current_req = fen
			var u = url % fen.replace(" ", "_").http_escape()
			Log.net(["REQUEST: get opening with url:", u])
			http_request.request(u)


func _request_completed(result, _response_code, _headers, byte_body):
	text = ""
	current_req = ""
	if result != OK:  # technically REQUEST_SUCCESS but i cant find it
		return
	var body = byte_body.get_string_from_utf8()
	Log.net("RECIEVED:" + body)
	var response = parse_json(body)

	if response.opening != null and "name" in response.opening:
		text = " %s" % response.opening.name

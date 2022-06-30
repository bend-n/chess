extends Node
class_name PGN

var movetextex = Utils.compile(
	"([NBKRQ]?[a-h]?[1-8]?[\\-x]?[a-h][1-8](?:=?[nbrqkNBRQK])?|[PNBRQK]?@[a-h][1-8]|--|Z0|0000|@@@@|O-O(?:-O)?|0-0(?:-0)?)|(\\{.*)|(;.*)|(\\$[0-9]+)|(\\()|(\\))|(\\*|1-0|0-1|1\\/2-1\\/2)|([\\?!]{1,2})"
)
var tagex = Utils.compile('^\\[([A-Za-z0-9_]+)\\s+"([^\\r]*)"\\]\\s*$')
var tagnameex = Utils.compile("^[A-Za-z0-9_]+\\Z")


func parse(pgn: String, tags := true) -> Dictionary:
	# put tags into a dictionary,
	# and the moves into a array
	var lines = Array(pgn.split("\n"))
	var headers := {}
	if tags:
		# get headers
		while !lines.empty():
			var line = lines[0].strip_edges()
			if !line or line[0] in ["%", ";"]:
				lines.pop_front()
				continue

			if line[0] != "[":
				break

			lines.pop_front()
			var tag_match = tagex.search(line)
			if tag_match:
				var cap = tag_match.strings
				if tagnameex.search(cap[1]):
					headers[cap[1]] = cap[2]
				else:
					# invalid headers
					return {}
			else:
				break
	var movetext := PoolStringArray()
	while !lines.empty():
		var line = lines.pop_front().strip_edges()
		if !line:
			break
		if line[0] in ["%", ";"]:
			continue
		for found in movetextex.search_all(line):
			if found.strings[1]:
				movetext.append(found.strings[1])
	return {"headers": headers, "moves": movetext}

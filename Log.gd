extends Node


static func info(information) -> void:  # logs the input string
	print("[i] " + to_str(information))


static func debug(information) -> void:  # logs the input string on debug builds
	if Debug.debug:
		print("[d] " + to_str(information))


static func err(information) -> void:  # logs the input string to stderr
	printerr("[E]" + to_str(information))


static func to_str(arg) -> String:
	if typeof(arg) == TYPE_ARRAY:
		return arr2str(arg)
	return str(arg)


static func arr2str(arr: Array) -> String:
	var string := ""
	for i in arr:
		string += str(i) + " "
	return string

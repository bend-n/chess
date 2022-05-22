extends Node
class_name Log


static func info(information) -> void:  # logs the input string
	print(to_str(information))


static func debug(information) -> void:  # logs the input string on debug builds
	if OS.is_debug_build():
		print(to_str(information))


static func err(information) -> void:  # logs the input string to stderr
	printerr(information)


static func to_str(arg) -> String:
	if typeof(arg) == TYPE_ARRAY:
		return arr2str(arg)
	elif typeof(arg) == TYPE_STRING:
		return arg
	else:
		err("Called with invalid arguments")
		return ""


static func arr2str(arr: Array) -> String:
	var string = ""
	for i in arr:
		string += str(i) + " "
	return string

extends Node
class_name Log

# static class


static func info(information) -> void:  # logs the input string
	print("(%s) [i] %s" % [now(), to_str(information)])


static func debug(information) -> void:  # logs the input string on debug builds
	if Debug.debug:
		print("(%s) [d] %s" % [now(), to_str(information)])


static func err(information) -> void:  # logs the input string to stderr
	push_error("(%s) [E] %s" % [now(), to_str(information)])


static func to_str(args) -> String:
	return arr2str(args) if typeof(args) == TYPE_ARRAY else str(args)


static func net(args) -> void:
	file("user://network_log.log", args)


static func file(path: String, args) -> void:
	SaveLoad.append_string(path, "(%s)%s" % [now(), to_str(args)])


static func now():
	var time = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [time.hour, time.minute, time.second]


static func arr2str(arr: Array) -> String:
	var string := ""
	for i in arr:
		string += "%s " % i
	return string

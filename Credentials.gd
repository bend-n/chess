extends Node
class_name Credentials

const default_id_data := {uuid = "", name = "", country = "rainbow", password = ""}
const file := "user://.chess.id"

var data := default_id_data


func _ready():
	var lod = SaveLoad.load(file)
	data = lod if Utils.dict_cmp(lod, default_id_data) else default_id_data
	if len(data.uuid) == 0:
		create_temporary_uuid()


func create_temporary_uuid():
	randomize()
	data.uuid = "A-%02x%02x%02x%02x-N" % [randi() % 256, randi() % 256, randi() % 256, randi() % 256]
	save()


func reset():
	data = default_id_data
	create_temporary_uuid()


func save() -> void:
	SaveLoad.save(file, data, false)


func get(property: String) -> String:
	return data[property]


func get_public() -> Dictionary:  # obviously the uuid isnt public. This actually just means ok for server: must not be used to send to other clients, directly. the id will be filtered out
	return {id = data.uuid, name = data.name, country = data.country}

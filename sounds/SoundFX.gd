extends Node

const soundpath := "res://sounds/"

var sounds := {
	"Check": load(soundpath + "Check.ogg"),
	"Error": load(soundpath + "Error.ogg"),
	"Victory": load(soundpath + "Victory.ogg"),
	"Move": load(soundpath + "Move.ogg"),
}

onready var sound_players := get_children()


func play(sound_string: String, pitch_scale: float = 1, volume_db: float = 0) -> void:
	for soundPlayer in sound_players:
		if not soundPlayer.playing:
			soundPlayer.pitch_scale = pitch_scale
			soundPlayer.volume_db = volume_db
			soundPlayer.stream = sounds[sound_string]
			soundPlayer.play()
			return

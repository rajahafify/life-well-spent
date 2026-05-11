## AudioManager — small audio system boundary; can be extended with buses/streams.
class_name AudioManager
extends Node

var last_sfx: String = ""
var music_track: String = ""


func play_sfx(name: String) -> void:
	last_sfx = name


func play_music(track_name: String) -> void:
	music_track = track_name


func stop_music() -> void:
	music_track = ""

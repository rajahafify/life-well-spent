## FeedbackSystem - game-wide juice boundary for effects that should outlive source nodes.
extends Node

const AUDIO_CUE_LIBRARY := preload("res://scripts/models/audio_cue_library.gd")

var last_sfx: String = ""
var spawned_sfx_count: int = 0


func reset() -> void:
	last_sfx = ""
	spawned_sfx_count = 0


func play_sfx(sfx_name: String, stream: AudioStream = null, bus_name: String = "SFX") -> AudioStreamPlayer:
	last_sfx = sfx_name
	spawned_sfx_count += 1
	if stream == null:
		stream = _stream_for_sfx(sfx_name)
	if stream == null:
		return null
	var player := AudioStreamPlayer.new()
	player.name = "SFX_%s" % sfx_name
	player.stream = stream
	player.bus = bus_name
	player.volume_db = AUDIO_CUE_LIBRARY.volume_db_for(sfx_name)
	add_child(player)
	player.finished.connect(player.queue_free)
	if is_inside_tree():
		player.play()
	return player


func _stream_for_sfx(sfx_name: String) -> AudioStream:
	var path := AUDIO_CUE_LIBRARY.path_for(sfx_name)
	if path == "":
		return null
	return load(path) as AudioStream

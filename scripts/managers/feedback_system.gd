## FeedbackSystem - game-wide juice boundary for effects that should outlive source nodes.
extends Node

var last_sfx: String = ""
var spawned_sfx_count: int = 0


func reset() -> void:
	last_sfx = ""
	spawned_sfx_count = 0


func play_sfx(sfx_name: String, stream: AudioStream = null, bus_name: String = "SFX") -> AudioStreamPlayer:
	last_sfx = sfx_name
	spawned_sfx_count += 1
	if stream == null:
		return null
	var player := AudioStreamPlayer.new()
	player.name = "SFX_%s" % sfx_name
	player.stream = stream
	player.bus = bus_name
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	return player

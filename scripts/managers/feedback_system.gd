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
	if path == "" or not FileAccess.file_exists(path):
		return null
	return _load_wav_stream(path)


func _load_wav_stream(path: String) -> AudioStreamWAV:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var bytes := file.get_buffer(file.get_length())
	file.close()
	if bytes.size() < 44:
		return null
	var channels := int(bytes.decode_u16(22))
	var sample_rate := int(bytes.decode_u32(24))
	var bits_per_sample := int(bytes.decode_u16(34))
	if bits_per_sample != 16:
		return null
	var data_offset := 36
	while data_offset + 8 <= bytes.size():
		var chunk_id := bytes.slice(data_offset, data_offset + 4).get_string_from_ascii()
		var chunk_size := int(bytes.decode_u32(data_offset + 4))
		if chunk_id == "data":
			var stream := AudioStreamWAV.new()
			stream.format = AudioStreamWAV.FORMAT_16_BITS
			stream.mix_rate = sample_rate
			stream.stereo = channels == 2
			stream.data = bytes.slice(data_offset + 8, data_offset + 8 + chunk_size)
			return stream
		data_offset += 8 + chunk_size
	return null

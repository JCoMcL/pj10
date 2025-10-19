extends Node

signal sfx_played(AudioStream)
signal music_played(AudioStream)

var audio_relay: Node3D

signal audio_relay_registered
func register_audio_relay(n: Node3D):
	audio_relay = n
	audio_relay_registered.emit()

var audio_relays = {}
func relay_audio(a2d: AudioStreamPlayer2D):
	if audio_relay:
		audio_relays[a2d] = audio_relay.relay(a2d)
	else:
		await audio_relay_registered
		relay_audio(a2d)

extends Node3D
class_name ArcadeGame

@export var subviewport: SubViewport
@export var observation_point: Node3D

@onready var speaker:AudioStreamPlayer3D = $TemplateSpeaker
@onready var screen:Sprite3D = $Sprite3D
@onready var capture_bus_idx = AudioServer.get_bus_index(&"Capture")

func _ready():
	assert(subviewport)
	screen.texture = subviewport.get_texture()
	Fuckit.register_audio_relay(self)

@onready var input_tracker = InputTracker.new()
func push_input(ev: InputEvent):
	input_tracker._input(ev)
	get_viewport().set_input_as_handled()
	subviewport.push_input(ev)

func relay(a2d: AudioStreamPlayer2D) -> AudioStreamPlayer3D:
	var a = AudioStreamPlayer3D.new()
	a.autoplay = a2d.autoplay
	a.bus = a2d.bus
	a.max_polyphony = a2d.max_polyphony
	a.pitch_scale = a2d.pitch_scale
	a.playing = a2d.playing
	a.stream = a2d.stream
	a.stream_paused = a2d.stream_paused
	a.volume_db = a2d.volume_db

	a.attenuation_model = speaker.attenuation_model
	a.panning_strength = speaker.panning_strength
	a.max_distance = speaker.max_distance
	add_child(a)
	return a

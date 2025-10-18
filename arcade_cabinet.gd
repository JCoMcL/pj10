extends Node3D

@export var subviewport: SubViewport

var capture:AudioEffectCapture
var playback:AudioStreamGeneratorPlayback

@onready var speaker:AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var screen:Sprite3D = $Sprite3D
@onready var capture_bus_idx = AudioServer.get_bus_index(&"Capture")

func _ready():
	assert(subviewport)
	var tex: ViewportTexture = $Sprite3D.texture
	tex.viewport_path = subviewport.get_path()
	
	capture = AudioServer.get_bus_effect(capture_bus_idx, 0)
	speaker
	speaker.stream = AudioStreamGenerator.new()
	speaker.play()
	playback = speaker.get_stream_playback()
	fill_buffer()

func _process(delta: float) -> void:
	fill_buffer()

func fill_buffer():
	var playback_available = playback.get_frames_available()
	var capture_available = capture.get_frames_available()
	# Fill the playback buffer until we run out of captured frames or playback frames
	while playback_available > capture_available:
		var buffer = capture.get_buffer(capture_available)
		playback.push_buffer(buffer)
		
		playback_available -= capture_available
		if playback_available <= 0:
			break
		capture_available = capture.get_frames_available()
		if capture_available <= 0:
			break

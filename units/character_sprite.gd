@tool
extends Sprite2D
class_name CharacterSprite2D

@export_range(0,16) var speed_frames: int = 0
@export_range(0,1000) var speed_start:float = 0.0
@export_range(0,3000) var speed_end:float = 1000.0
@export var vertical_speed_only = false
@export_range(0,16) var randomize_frames: int
@export_range(0, 60, 1, "suffix:fps") var randomize_rate = 0
#NOTE: if speed_frames and randomize_frames are both nonzero, behaviour is undefined.
# We'll wait until we have a usecase to sort that out
@export var random_hflip = false
@export var random_vflip = false

@onready var unit: Unit = get_parent()

func randomize_sprite():
	assert(randomize_frames)
	frame = range(speed_frames, speed_frames + randomize_frames).pick_random()

func set_speed_frame(delta: float):
	assert(speed_frames > 1)
	var speed_sqr = unit.velocity.y ** 2 if vertical_speed_only else unit.velocity.length_squared()
	var _frame = 0
	var speed_interval = (speed_end - speed_start) / speed_frames
	for i in range(speed_frames):
		if speed_sqr <= (speed_start + speed_interval * i) ** 2:
			break
		_frame += 1

	frame = min(_frame, speed_frames-1)

var randomize_accum: float
func _process(delta: float) -> void:
	if speed_frames:
		set_speed_frame(delta)
	if randomize_rate and not Engine.is_editor_hint():
		var randomize_frame_time = 1.0/randomize_rate
		randomize_accum += delta
		while randomize_accum > randomize_frame_time:
			randomize_accum -= randomize_frame_time
			randomize_sprite()

func _ready() -> void:
	if randomize_frames:
		randomize_sprite()
	if random_hflip:
		flip_h = randf() > 0.5
		print(flip_h)
	if random_vflip:
		flip_v = randf() > 0.5

func _get_configuration_warnings() -> PackedStringArray:
	var out = []
	var p = get_parent()
	if not p or p is not Unit:
		out.append("Parent must by Unit")
	return out

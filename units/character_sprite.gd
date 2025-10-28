@tool
extends Sprite2D
class_name CharacterSprite2D

@export_range(0,16) var animation_frames: int = 0
@export_range(0, 60, 1, "suffix:fps") var animation_rate = 0
@export_range(0,16) var randomize_frames: int
@export_range(0, 60, 1, "suffix:fps") var randomize_rate = 0
@export_range(0, 60, 1, "suffix:fps") var strobe_rate = 0
@export_range(0,16) var speed_frames: int = 0
@export_range(0,1000) var speed_start:float = 0.0
@export_range(0,3000) var speed_end:float = 1000.0
@export_range(0,16) var damage_frames: int = 0
@export var vertical_speed_only = false
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

func advance_animation():
	if frame >= animation_frames - 1:
		frame = 0
	else:
		frame += 1

func advance_damage():
	var d = damage_frames-1
	frame = d - d * unit.current_health / unit.health

func strobe():
	visible = !visible

var cumers: Array[Cumer]
func _process(delta: float) -> void:
	if speed_frames:
		set_speed_frame(delta)
	for c in cumers:
		c.add(delta)

func _ready() -> void:
	if randomize_frames:
		randomize_sprite()
		if randomize_rate > 0:
			cumers.append(Cumer.new(randomize_rate, randomize_sprite))
	if animation_frames and animation_rate > 0:
		cumers.append(Cumer.new(animation_rate, advance_animation))
	if strobe_rate:
		cumers.append(Cumer.new(strobe_rate, strobe))
	if damage_frames and not Engine.is_editor_hint():
		unit.hit.connect(advance_damage)
	if random_hflip:
		flip_h = randf() > 0.5
	if random_vflip:
		flip_v = randf() > 0.5

func _get_configuration_warnings() -> PackedStringArray:
	var out = []
	var p = get_parent()
	if not p or p is not Unit:
		out.append("Parent must by Unit")
	return out

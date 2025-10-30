@tool
extends EffectSprite2D
class_name CharacterSprite2D

@export_range(0,16) var speed_frames: int = 0
@export_range(0,1000) var speed_start:float = 0.0
@export_range(0,3000) var speed_end:float = 1000.0
@export_range(0,16) var damage_frames: int = 0
@export var vertical_speed_only = false

@onready var unit: Unit = get_parent()

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

func advance_damage():
	var d = damage_frames-1
	frame = d - d * unit.current_health / unit.health

func _ready() -> void:
	super()
	if damage_frames and not Engine.is_editor_hint():
		unit.hit.connect(advance_damage)

func _process(delta: float):
	if speed_frames:
		set_speed_frame(delta)
	super(delta)

func _get_configuration_warnings() -> PackedStringArray:
	var out = []
	var p = get_parent()
	if not p or p is not Unit:
		out.append("Parent must by Unit")
	return out

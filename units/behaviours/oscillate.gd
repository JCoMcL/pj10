class_name Oscillate
extends Behaviour

@export_range(0.01, 10) var frequency = 1.0
@export var amplitude = 1
const time_factor = TAU / 1000
var time_offset: float

func _initialize(u: Unit):
	super(u)
	time_offset = randf() * TAU

func _process(u: Unit, delta: float):
	super(u, delta)
	u.position.x += sin((Time.get_ticks_msec() * time_factor + time_offset) * frequency) * amplitude * delta * frequency

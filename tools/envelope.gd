extends Resource
class_name Envelope

@export_range(0, 10, 0.01, "suffix:s") var attack = 0.0
@export_range(0, 10, 0.01, "suffix:s") var decay = 0.0
@export_range(0, 1) var sustain = 1.0
@export_range(0, 10, 0.01, "suffix:s") var release = 0.0

func value(time: float, active = true) -> float:
	assert(time >= 0)
	if active:
		if time < attack:
			assert(attack > 0)
			return time/attack
		time -= attack
		if time < decay:
			assert(decay > 0)
			return lerp(1.0, sustain, time/decay)
		time -= decay
		return sustain
	else:
		if time < release:
			assert(release > 0)
			return lerp(sustain, 0.0, time/release)
		return 0

func value_from_timer(t: SceneTreeTimer, active = true) -> float:
	if active:
		return value(attack + decay - t.time_left, active)
	else:
		return value(release - t.time_left, active)

func create_timer(n: Node, active: bool):
	if active:
		return n.get_tree().create_timer(attack + decay)
	return n.get_tree().create_timer(release)

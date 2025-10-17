class_name Inertial #NOTE: behaviours that move based on velocity should inherit from this
extends Behaviour

@export_range(0, 10) var drag = 0

func _process(u: Unit, delta: float):
	super(u, delta)
	var decay := clampf(1.0 - drag * delta, 0.0, 1.0)
	u.velocity *= decay
	move_and_collide(u, u.velocity * delta)

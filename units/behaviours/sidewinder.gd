class_name Sidewinder
extends Behaviour

@export var speed = 100 # pixels per second
@export var turn_speed = 10 #radians per second
var target_direction = Vector2.RIGHT

func turn_radius() -> float:
	var omega: float = float(max(turn_speed, 0.001))
	return (speed / omega)

func _process(u: Unit, delta: float):
	if not u.direction:
		u.direction = target_direction

	if not is_equal_approx(u.direction.x, target_direction.x):
		u.direction = u.direction.rotated( min(
			abs(target_direction.angle_to(u.direction)),
			abs(turn_speed * delta)
		) * -sign(target_direction.x) )
	else:
		u.direction = target_direction

	if u.move_and_collide(u.direction * (turn_radius() * 1.5), true):
		target_direction = Vector2(-u.direction.x, 0).normalized()

	move_and_collide(u, u.direction * speed * delta)

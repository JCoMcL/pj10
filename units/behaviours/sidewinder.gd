class_name Sidewinder
extends Behaviour

@export var speed = 100
@export var turn_speed = 10
var target_direction = Vector2.RIGHT
var direction = target_direction
func _process(c: CharacterBody2D, delta: float):
	if not is_equal_approx(direction.x, target_direction.x):
		direction = direction.rotated( min(
			abs(target_direction.angle_to(direction)),
			abs(turn_speed * delta)
		) * -sign(target_direction.x) )
	else:
		direction = target_direction

	var test_margin = 0.4
	if c.move_and_collide(direction * speed * test_margin, true):
		target_direction = Vector2(-direction.x, 0).normalized()

	var expected_position = c.position + direction * speed * delta
	c.move_and_collide(direction * speed * delta)
	if c.position.distance_squared_to(expected_position) > 10:
		print("whoospie :#")
		c.position = expected_position

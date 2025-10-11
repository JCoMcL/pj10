extends CharacterBody2D


class Behaviour:
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

		c.move_and_collide(direction * speed * delta)

var behaviours = [Behaviour.new()]

signal expire

func _hit():
	queue_free()

func _physics_process(delta: float) -> void:
	for b in behaviours:
		b._process(self, delta)


extends CharacterBody2D

@export var speed = 100
@export var turn_speed = 10

var pma = Pool.MemberAttributes.new(self)

func _hit():
	queue_free()

var target_direction = Vector2.RIGHT
var direction = target_direction
func _physics_process(delta: float) -> void:
	if not is_equal_approx(direction.x, target_direction.x):
		direction = direction.rotated( min(
			abs(target_direction.angle_to(direction)),
			abs(turn_speed * delta)
		) * -sign(target_direction.x) )
	else:
		direction = target_direction

	var test_margin = 0.4
	if move_and_collide(direction * speed * test_margin, true):
		target_direction = Vector2(-direction.x, 0).normalized()

	move_and_collide(direction * speed * delta)

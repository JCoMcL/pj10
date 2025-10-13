class_name BulletBehaviour
extends Behaviour

@export var speed = 240

func _process(c: CharacterBody2D, delta: float):
	var hit = c.move_and_collide(Vector2.UP * speed * delta)
	if hit:
		var struck_object = hit.get_collider()
		if struck_object.has_method("_hit"):
			struck_object._hit()
		c._expire()


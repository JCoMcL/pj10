class_name Bullet
extends Deadly

@export var speed = 240

func _process(u: Unit, delta: float):
	move_and_collide(u, Vector2.UP * speed * delta)

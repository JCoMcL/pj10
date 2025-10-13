class_name Behaviour
extends Resource

func _handle_collision(struck_object: Node2D, u: Unit):
	pass

func move_and_collide(u: Unit, motion: Vector2):
	var k = u.move_and_collide(motion)
	if k and k.get_collider():
		u.handle_collision(k.get_collider())

func _process(u: Unit, delta: float):
	pass

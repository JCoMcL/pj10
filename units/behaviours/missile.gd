class_name Missile
extends Behaviour

@export var speed = 240

func _handle_collision(struck_object: Node2D, u: Unit):
	super(struck_object, u)

func _process(u: Unit, delta: float):
	move_and_collide(u, u.direction * speed * delta)

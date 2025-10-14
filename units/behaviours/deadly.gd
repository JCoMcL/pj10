class_name Deadly
extends Behaviour

@export var also_die = true

func _handle_collision(struck_object: Node2D, u: Unit):
	super(struck_object, u)
	if struck_object.has_method("_hit"):
		struck_object._hit()
	if also_die:
		u._expire()

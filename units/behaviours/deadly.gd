class_name Deadly
extends Behaviour

@export_flags_2d_physics var ignore_layers = 0
@export var also_die = true
@export var damage = 1

func _handle_collision(struck_object: Node2D, u: Unit):
	super(struck_object, u)
	if struck_object.collision_layer & ~ignore_layers:
		if struck_object.has_method("_hit"):
			struck_object._hit(damage)
		if also_die:
			u._expire()

extends Node2D

func _input(ev: InputEvent):
	if ev is InputEventMouseButton and ev.is_pressed():
		for o in Utils.get_objects_at(
			ev.position
		):
			if o.has_method("_hit"):
				o._hit()

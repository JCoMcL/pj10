extends Interactable

func interact(body):
	super(body)
	Fuckit.power_on.emit()
	var switch = get_parent().get_node("level/Breaker Panel/Breakers_001")
	switch.rotation.z = deg_to_rad(90)
	$AudioStreamPlayer3D.play()
	collision_layer = 0

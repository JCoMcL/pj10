extends Shoota
class_name Scattershot

func shoot(direction:Vector2, parent:Node=null, mask:int=-1) -> Unit:
	var out: Unit
	for i in range(ammo_count):
		var bullet = await super(direction, parent, mask)
		if bullet:
			out = bullet
		else:
			break
	return out

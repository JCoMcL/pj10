extends Shoota
class_name Scattershot

func shoot(towards:Variant, parent:Node=null, mask:int=-1) -> Unit:
	var out: Unit
	for i in range(ammo_count):
		var bullet = await super(towards, parent, mask)
		if bullet:
			out = bullet
		else:
			break
	return out

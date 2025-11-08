extends Player

func bomb():
	velocity.x = 1200 * (-1 if get_sprite().flip_h else 1)
	super()

extends Player

func bomb():
	if await super():
		velocity.x = 1200 * (-1 if get_sprite().flip_h else 1)
		return true
	return false

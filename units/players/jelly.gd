extends Player

func reset_bomb_cooldown():
	if active_bomb and active_bomb.alive:
		return
	super()


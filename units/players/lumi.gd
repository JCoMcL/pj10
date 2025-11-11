extends Player

func bomb():
	if await super():
		var dash_direction = sign(direction.x)
		if not dash_direction:
			dash_direction = (-1 if get_sprite().flip_h else 1)
		velocity.x = 1200 * dash_direction
		get_sprite().visible = false
		play_sfx("swish")
		grace_window(0.3)
		return true
	return false

func choose_frame(delta) -> int:
	if abs(velocity.x) > 800:
		return Frames.SPECIAL
	return super(delta)

func _process(delta):
	super(delta)
	if bomb_active_time() < 0.4:
		shoota.autoshoot = false

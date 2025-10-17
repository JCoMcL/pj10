extends Unit

func wakeup() -> void:
	super()
	play_sfx("pip")
	$Sprite2D.modulate = Game.get_game(self).get_team_color(self)

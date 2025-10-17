extends Unit
class_name Bullet

@export var payload: PackedScene

func _expire():
	if payload:
		Game.add_to_playfield(payload.instantiate(), self)
	super()

func wakeup() -> void:
	super()
	play_sfx("pip")
	$Sprite2D.modulate = Game.get_game(self).get_team_color(self)

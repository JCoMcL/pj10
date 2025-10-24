extends Unit
class_name Bullet

@export var payload: PackedScene
@export var hit_sfx = "pip"

func _expire():
	if not alive:
		return
	if hit_sfx:
		play_sfx(hit_sfx)
	if payload:
		Game.add_to_playfield(payload.instantiate(), self)
	super()

extends Unit
class_name Bullet

@export var payload: PackedScene
@export var hit_sfx = "pip"

func _expire():
	if hit_sfx:
		play_sfx(hit_sfx)
	if not alive:
		return
	if payload_instance:
		if payload_instance is Unit:
			payload_instance.collision_mask = collision_mask
		Game.add_to_playfield(payload_instance, self)
		if payload_instance is Shoota:
			payload_instance.shoot(direction, null, collision_mask)
	super()

var payload_instance: Node
func _ready():
	if payload:
		payload_instance = payload.instantiate()
	super()

extends Node
class_name VFX

func acquire(at:Node2D, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs: VFXSprite = await pool.next(at)
	assert(vs)
	assert(at and is_instance_valid(at))
	Game.add_to_playfield(vs, at)
	vs.position += offset
	vs.reset_physics_interpolation()
	return vs

func pop(at:Node2D, offset: Vector2=Vector2.ZERO) -> VFXSprite:
	var vs:VFXSprite = await acquire(at, offset)
	vs.play(effects.pop[0], effects.pop[1], 20)
	return vs

var json = preload("res://vfx/vfx.json")
var effects: Dictionary
var pool: Pool
func _ready():
	pool=Pool.new(preload("res://vfx/v_effect.tscn"), 16)
	for tag in json.data.meta.frameTags:
		effects[tag.name] = [int(tag.from), int(tag.to)]

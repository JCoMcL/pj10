extends Node2D
class_name Shoota

@export var ammo: PackedScene:
	set(scn):
		assert(scn.instantiate() is Unit)
		ammo = scn

@export_range(1,64,1) var ammo_count = 3
@export var pool_mode: Pool.Poolmode = Pool.Poolmode.PASS
@export_range(0.0, 10.0) var interval = 0.0

@onready var bullet_pool = Pool.new(ammo, ammo_count, pool_mode, true, false)

func find_first_node_not_under_unit() -> Node:
	var ancestry = Utils.get_ancestry(self)
	var candidate: Node
	for n in ancestry:
		if n is Unit or n is FauxUnit:
			return candidate
		candidate = n
	return candidate

var timer: SceneTreeTimer
func shoot(direction:Vector2, parent:Node=null, mask:int=-1) -> Unit:
	if timer and timer.time_left:
		return null

	if not parent:
		parent = Game.get_game(self).new_entity_region
	if not parent:
		parent = find_first_node_not_under_unit() # yes it really is that complicated

	if mask == -1:
		mask = Utils.combined_layers(["World", "Friendly", "Enemy"]) & ~get_parent().collision_layer

	var bullet = await bullet_pool.next(parent)
	if bullet:
		assert(bullet is Unit)
		bullet.collision_mask = mask
		bullet.global_position = global_position
		bullet.direction = direction.normalized()
		bullet.wakeup()

		if interval > 0:
			timer = get_tree().create_timer(interval)
		return bullet
	return null

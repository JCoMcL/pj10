extends Node2D
class_name Shoota

@export var ammo: PackedScene:
	set(scn):
		assert(scn.instantiate() is Unit)
		ammo = scn

@onready var bullet_pool = Pool.new(ammo, 3, Pool.PASS, true, false)

func find_first_node_not_under_unit() -> Node:
	var ancestry = Utils.get_ancestry(self)
	var candidate: Node
	for n in ancestry:
		if n is Unit or n is FauxUnit:
			return candidate
		candidate = n
	return candidate

func shoot(direction:Vector2, parent:Node=null, mask:int=-1) -> bool:
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
		return true
	return false

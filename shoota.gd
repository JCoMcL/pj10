extends Node2D
class_name Shoota

@export var ammo: PackedScene:
	set(scn):
		assert(scn.instantiate() is Unit)
		ammo = scn

@onready var bullet_pool = Pool.new(ammo, 3, Pool.PASS, true, false)

func shoot(direction: Vector2, parent: Node=null):
	if not parent:
		parent = get_parent()
		while parent is Unit:
			parent = parent.get_parent()

	var bullet = await bullet_pool.next(parent)
	if bullet:
		assert(bullet is Unit)
		bullet.global_position = global_position
		bullet.direction = direction.normalized()

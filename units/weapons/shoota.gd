extends Node2D
class_name Shoota

@export var ammo: PackedScene:
	set(scn):
		assert(scn.instantiate() is Unit)
		ammo = scn

@export_range(1,64,1) var ammo_count = 3
@export var pool_mode: Pool.Poolmode = Pool.Poolmode.PASS
@export_range(0.0, 10.0) var interval = 0.0
@export_range(0, 360, 1, "radians_as_degrees") var spread: float = 0
@export var apply_impulse: float = 0
@export var autoshoot = false
@export var oneshot = false
@export var default_direction = Vector2.UP
@export var shoot_sfx: StringName = "bew"
@export_range(0,1) var run_and_gun: float = 1
@export_range(0,6) var run_and_gun_recovery_time: float = 1

var _rag_rec = 1.0
func get_speed_modifier(delta: float) -> float:
	_rag_rec = move_toward(_rag_rec, 1.0, delta / run_and_gun_recovery_time)
	return lerp(run_and_gun, 1.0, _rag_rec)

@onready var bullet_pool = Pool.new(ammo, ammo_count, pool_mode, true, false)

func find_first_node_not_under_unit() -> Node:
	var ancestry = Utils.get_ancestry(self)
	var candidate: Node
	for n in ancestry:
		if n is Unit or n is FauxUnit:
			return candidate
		candidate = n
	return candidate

func auto_shoot(direction:Vector2 = default_direction, parent:Node=null, mask:int=-1):
	if autoshoot:
		shoot(direction, parent, mask)

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
		bullet.direction = direction.normalized().rotated((randf() - 0.5) * spread)
		bullet.velocity += bullet.direction * apply_impulse
		bullet.wakeup()

		if not oneshot and interval > 0:
			timer = get_tree().create_timer(interval)
			timer.timeout.connect(auto_shoot.bind(direction, parent, mask))
		SFXPlayer.get_sfx_player(self).play_sfx(shoot_sfx)
		_rag_rec = 0
		return bullet
	return null

func _ready():
	auto_shoot()

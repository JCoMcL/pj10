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
@export var autoshoot = false:
	set(b):
		if autoshoot != b and run_and_gun_envelope:
			ragtime = run_and_gun_envelope.create_timer(self, b)
		autoshoot = b
@export var oneshot = false
@export var default_direction = Vector2.UP
@export var shoot_sfx: StringName = "bew"
@export_range(0,1) var run_and_gun: float = 1
@export var run_and_gun_envelope: Envelope

signal points_claimed(int)

var bullet_pool: Pool

var ragtime: SceneTreeTimer
func get_speed_modifier(delta: float) -> float:
	if run_and_gun_envelope and ragtime:
		return 1.0 - run_and_gun_envelope.value_from_timer(ragtime, autoshoot)
	return run_and_gun if autoshoot else 1.0

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

signal winding_up
signal wound_up
func windup():
	winding_up.emit()

var timer: SceneTreeTimer
func shoot(towards:Variant = default_direction, parent:Node=null, mask:int=-1) -> Unit:
	if timer and timer.time_left:
		return null

	await windup()
	wound_up.emit()

	var direction: Vector2
	if towards is Vector2:
		direction = towards.normalized()
	elif towards is Node2D:
		direction = (towards.global_position - global_position).normalized()
	else:
		assert(false)
		direction = default_direction

	if not parent:
		var game = Game.get_game(self)
		if game:
			parent = game.new_entity_region
	if not parent:
		parent = find_first_node_not_under_unit() # yes it really is that complicated

	if mask == -1:
		mask = Utils.combined_layers(["World", "Friendly", "Enemy"]) & ~get_parent().collision_layer

	var bullet: Unit
	if bullet_pool:
		bullet = await bullet_pool.next(parent)
	if bullet:
		assert(bullet is Unit)
		bullet.collision_mask = mask
		bullet.setup_team()
		bullet.global_position = global_position
		bullet.direction = direction.normalized().rotated((randf() - 0.5) * spread)
		bullet.velocity += bullet.direction * apply_impulse

		if not bullet.points_claimed.is_connected(points_claimed.emit):
			bullet.points_claimed.connect(points_claimed.emit)

		bullet.wakeup()

	if not oneshot and interval > 0:
		timer = get_tree().create_timer(interval)
		timer.timeout.connect(auto_shoot.bind(direction, parent, mask))
	SFXPlayer.get_sfx_player(self).play_sfx(shoot_sfx)

	if run_and_gun_envelope and not autoshoot:
		ragtime = run_and_gun_envelope.create_timer(self, autoshoot)

	return bullet

func _ready():
	if ammo:
		bullet_pool = Pool.new(ammo, ammo_count, pool_mode, true, false)
	if run_and_gun_envelope and autoshoot:
		ragtime = run_and_gun_envelope.create_timer(self, autoshoot)
	auto_shoot()

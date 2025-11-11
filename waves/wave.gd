extends FauxUnit
class_name Wave

@export var starting_formation: PackedScene
@export var interceptor: PackedScene
@export var marten: PackedScene

# --- Modifying

func nothing(n: Node2D):
	pass

func spread(n: Node2D, amount = 32.0):
	n.position += Vector2(
		randf() - 0.5,
		randf() - 0.5
	) * amount
	n.reset_physics_interpolation()

func nudge(n: Node2D, x=0.0, y=0.0):
	n.position += Vector2(x,y)
	n.reset_physics_interpolation()

# --- Spawning ---

func get_spawnpoint(s: StringName) -> SpawnPoint:
	for n in get_parent().get_children():
		if n is SpawnPoint and n.name == s:
			return n
	assert(false)
	return null

func spawn_at(scn: PackedScene, spawnpoint: StringName, modify: Callable = nothing) -> Node:
	var n = scn.instantiate()
	await add_subunit(n, get_spawnpoint(spawnpoint))
	modify.call(n)
	return n

func spawn_chain(scn: PackedScene, spawnpoint: StringName, count: int, interval: float = 1.0, modify: Callable = nothing):
	for i in range(count):
		spawn_at(scn, spawnpoint, modify)
		await Utils.delay(interval)

func spawn_left_interceptors():
	spawn_chain(interceptor, "Edge", 9, 1, func(n: Unit):
		n.direction = Vector2.RIGHT
		n.expire_outside_play_area = true
	)

func spawn_right_interceptors():
	spawn_chain(interceptor, "Edge_M", 9, 1, func(n: Unit):
		n.direction = Vector2.LEFT
		n.expire_outside_play_area = true
		nudge(n, 0, -18)
	)

func _expire():
	if done_spawning:
		super()
	else:
		print("%s: Warn: Attempted expire before done spawning" % self)

func finish_up():
	done_spawning = true
	if not get_units(): # they're all dead
		_expire()

var done_spawning = false
func start():
	var current: Node
	current = await spawn_at(starting_formation, "FormationCorner")
	current.position.y += 40
	current.reset_physics_interpolation()
	await Utils.delay(15)
	spawn_left_interceptors()
	await Utils.delay(6)
	await spawn_right_interceptors()
	await Utils.delay(15)
	await spawn_chain(marten, "CenterSpawn", 2, 2.0, spread)
	await Utils.delay(5)
	spawn_at(marten, "PincerSpawn")
	await Utils.delay(1)
	spawn_at(marten, "PincerSpawn_M")

	finish_up()

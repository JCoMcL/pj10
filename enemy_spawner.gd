extends FauxUnit

@export var starting_formation: PackedScene
@export var interceptor: PackedScene

func get_spawnpoint(s: StringName) -> SpawnPoint:
	for n in get_parent().get_children():
		if n is SpawnPoint and n.name == s:
			return n
	assert(false)
	return null

func spawn_at(scn: PackedScene, spawnpoint: StringName) -> Node:
	var n = scn.instantiate()
	await add_subunit(n, get_spawnpoint(spawnpoint))
	return n

func spawn_left_interceptors():
	var current: Node
	for i in range(9):
		current = await spawn_at(interceptor, "Edge")
		current.direction = Vector2.RIGHT
		current.expire_outside_play_area = true
		await Utils.delay(1)

func spawn_right_interceptors():
	var current: Node
	for i in range(9):
		current = await spawn_at(interceptor, "Edge_M")
		current.direction = Vector2.LEFT
		current.expire_outside_play_area = true
		current.position.y += 18
		await Utils.delay(1)

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
	await Utils.delay(15)
	spawn_left_interceptors()
	await Utils.delay(6)
	await spawn_right_interceptors()
	finish_up()

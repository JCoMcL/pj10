extends Marker2D

@export var enemy: PackedScene
@onready var pool = Pool.new(enemy, 100, self)

func delay(secs):
	await get_tree().create_timer(secs).timeout

func spawn_rank(count, gap):
	for i in range(count):
		pool.next()
		await delay(gap)

func _ready():
	await spawn_rank(20, 1)
	await delay(2)
	await spawn_rank(10, 0.5)
	await delay(2)
	for i in range(5):
		await spawn_rank(5, 0.2)
		await delay(0.5)
	await spawn_rank(20, 0.3)
	await spawn_rank(5, 0.2)

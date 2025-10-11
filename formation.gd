@tool
extends CharacterBody2D

@export var unit: PackedScene:
	set(val):
		unit = val
		refresh()
@export_range(1,20) var rank: int = 1:
	set(val):
		rank = val
		refresh()
@export_range(1,20) var file: int = 1:
	set(val):
		file = val
		refresh()
@export_range(0, 100) var spacing: float:
	set(val):
		spacing = val
		refresh()
@export var staggered: bool:
	set(val):
		staggered = val
		refresh()

var units: Array[CharacterBody2D]
func clean():
	for c in units:
		if is_instance_valid(c):
			c.queue_free()
	units = []


func refresh():
	if Engine.is_editor_hint():
		setup()

func setup():
	clean()
	var unit_bounds: Vector2
	for i in range(rank):
		for j in range(file):
			var c = unit.instantiate()
			if not unit_bounds:
				unit_bounds = Utils.get_global_rect(c).size
			add_child(c)
			units.append(c)
			c.position = Vector2(
				(i + (((j % 2) / 2.0) if staggered else 0.0)) * (unit_bounds.x + spacing),
				j * (unit_bounds.y + spacing)
			)

	var child_rects: Array[Rect2]
	child_rects.assign(units.map(func(u): return Utils.get_global_rect(u)))
	var r = Utils.localise_rect(Utils.union_rect(child_rects), self)
	var shape = RectangleShape2D.new()
	shape.size = r.size
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = r.size / 2 + r.position

func _ready():
	setup()

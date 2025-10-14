@tool
extends Unit

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

var _to_remove: Unit # helps us avoid race conditions
func get_units() -> Array[Unit]:
	var out: Array[Unit]
	for c in $Container.get_children():
		if c is Unit and c.alive and c != _to_remove:
			out.append(c)
	return out

var unit_count = 0
func on_unit_expire(u: Unit):
	_to_remove = u
	unit_count -= 1
	if unit_count == 0:
		return _expire()
	if unit_count < 5:
		assert(get_units().size() == unit_count)
	set_bounds()

func clean():
	for c in get_children():
		if c is Unit:
			c.free()

	for c in get_units():
		if is_instance_valid(c):
			c.free()

var is_setup = false
func refresh():
	clean()
	is_setup = false
	if Engine.is_editor_hint():
		setup.call_deferred()

func set_bounds():
	var child_rects: Array[Rect2]
	child_rects.assign(get_units().map(func(u): return Utils.get_global_rect(u)))
	var r = Utils.localise_rect(Utils.union_rect(child_rects), self)
	var shape = RectangleShape2D.new()
	shape.size = r.size
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = r.size / 2 + r.position

func setup():
	if is_setup:
		return
	clean()
	if unit:
		var unit_bounds: Vector2
		for i in range(rank):
			for j in range(file):
				var c: Unit = unit.instantiate()
				c.expire.connect(on_unit_expire.bind(c), CONNECT_ONE_SHOT)
				if not unit_bounds:
					unit_bounds = Utils.get_global_rect(c).size
				$Container.add_child(c)
				c.position = Vector2(
					(i + (((j % 2) / 2.0) if staggered else 0.0)) * (unit_bounds.x + spacing),
					j * (unit_bounds.y + spacing)
				)
				unit_count += 1

	set_bounds()
	is_setup = true

func _ready():
	super()
	if not is_setup:
		setup()

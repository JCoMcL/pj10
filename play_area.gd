@tool
extends Area2D
class_name PlayArea

@export_range(0, 2000) var width = 200:
	set(w):
		width = w
		refresh()

@export_range(0, 2000) var height = 100:
	set(h):
		height = h
		refresh()

@export var ceiling = true:
	set(b):
		if not b and has_node("UpWall"):
			$UpWall.free()
		ceiling = b
		refresh()
@export var left_wall = true:
	set(b):
		if not b and has_node("LeftWall"):
			$LeftWall.free()
		left_wall = b
		refresh()
@export var right_wall = true:
	set(b):
		if not b and has_node("RightWall"):
			$RightWall.free()
		right_wall = b
		refresh()

## Expose components for viewing and editing.
## May cause strange bugs if left on
@export var viewable: bool = false:
	set(b):
		viewable = b
		refresh()

func refresh():
	if not _set_up:
		return
	if Engine.is_editor_hint():
		setup_region.call_deferred()

func get_component(path: NodePath, type: Variant) -> Node:
	var out = get_node_or_null(path)
	if not out:
		out = type.new()
		out.name = path.get_name(path.get_name_count() -1)
		var parent = self
		if path.get_name_count() > 1:
			parent = get_node(NodePath(path.get_name(path.get_name_count() - 2)))

		parent.add_child(out)
		
	elif typeof(out) != typeof(type):
		out.free()
		return get_component(path, type)
	
	out.owner = get_tree().edited_scene_root if viewable else null
	return out

func get_inner_shape() -> CollisionShape2D:
	return get_component("CollisionShape2D", CollisionShape2D)

func get_wall(d: int) -> StaticBody2D:
	return get_component("%sWall" % Direction.pretty(d), StaticBody2D)

func get_wall_collider(d: int) -> CollisionShape2D:
	return get_component("%sWall/CollisionShape2D" % Direction.pretty(d), CollisionShape2D)

func get_background() -> ColorRect:
	return get_component("Background", ColorRect)

func set_region(w,h):
	var end = Vector2(w,h)
	var center = end / 2

	var shape = get_inner_shape()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = end
	shape.position = center
	
	var background = get_background()
	background.size = end
	background.z_index = -1

	var active_walls = [ceiling, true, left_wall, right_wall]
	for direction in Direction.each:
		if active_walls[direction]:
			var wall = get_wall(direction)
			wall.position = Direction.to_vec(direction) * center + center
			var wall_collider = get_wall_collider(direction)
			wall_collider.shape = WorldBoundaryShape2D.new()
			wall_collider.rotation = Direction.to_radians(direction) - (PI /2)
			wall_collider.one_way_collision = true
			wall_collider.one_way_collision_margin = 50

func setup_region():
	set_region(width, height)

var _set_up = false
func _ready():
	setup_region()
	_set_up = true

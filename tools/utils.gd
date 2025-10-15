@tool
extends Node

# --- collision ---

var layers: Dictionary[String, int]:
	get():
		if ! layers:
			for i in range(32):
				var layer_name = ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % i)
				if layer_name:
					layers[layer_name] = 2 ** (i-1)
			print("Generated layer map:", layers)
		return layers

func combined_layers(layer_names: Array[String]):
	var out = 0
	for s in layer_names:
		out |= layers[s]
	return out

func seperate_layers(i: int) -> Array[String]:
	var out: Array[String]
	for k in layers.keys():
		if i & layers[k]:
			out.append(k)
	return out

enum {AREAS, BODIES, AREAS_AND_BODIES}
func get_objects_at(where: Vector2, mask=65535, collider_type=AREAS_AND_BODIES, world: World2D=null):
	var pq := PhysicsPointQueryParameters2D.new()
	pq.collide_with_areas = (collider_type == AREAS || collider_type == AREAS_AND_BODIES)
	pq.collide_with_bodies = (collider_type == BODIES || collider_type == AREAS_AND_BODIES)
	pq.collision_mask = layers[mask] if mask is String else mask
	pq.position = where

	if ! world:
		world=get_viewport().get_world_2d()

	return world.direct_space_state.intersect_point(pq).map(func (d): return d.collider)

# --- coordinates ---

func viewport_to_world(v: Vector2, relative_to: Node = self):
	var vp = relative_to.get_viewport()
	return vp.global_canvas_transform.affine_inverse() * vp.canvas_transform.affine_inverse() * v

# --- rects ---

func union_rect(a: Array[Rect2]) -> Rect2:
	if not a:
		return Rect2()

	var top_left = a[0].position
	var bottom_right = a[0].end
	for r in a:
		top_left.x = r.position.x if r.position.x < top_left.x else top_left.x
		top_left.y = r.position.y if r.position.y < top_left.y else top_left.y
		bottom_right.x = r.end.x if r.end.x > bottom_right.x else bottom_right.x
		bottom_right.y = r.end.y if r.end.y > bottom_right.y else bottom_right.y

	return Rect2(top_left, bottom_right - top_left)

func globalise_rect(r: Rect2, rect_owner: Node2D):
	r.position *= rect_owner.global_scale
	r.position += rect_owner.global_position
	r.size *= rect_owner.global_scale
	return r

func localise_rect(r: Rect2, rect_owner: Node2D):
	r.position -= rect_owner.global_position
	r.position /= rect_owner.global_scale
	r.size /= rect_owner.global_scale
	return r

func get_global_rect(n: Node2D) -> Rect2:
	if n.has_method("get_global_rect"):
		return n.get_global_rect()
	if n.has_method("get_rect"):
		return globalise_rect(n.get_rect(), n)
	if n is CollisionObject2D:
		var shape_rects: Array[Rect2]
		for id in n.get_shape_owners():
			var offset = n.shape_owner_get_transform(id).origin
			for i in n.shape_owner_get_shape_count(id):
				var r = n.shape_owner_get_shape(id, i).get_rect()
				r.position += offset
				shape_rects.append(r)
		return globalise_rect(union_rect(shape_rects), n)
	push_warning("Warn: get_global_rect: no support for object: %s" % n)
	return Rect2()

func get_local_rect(n: Node2D) -> Rect2:
	return localise_rect(get_global_rect(n), n)

# --- nodes ---

func get_ancestry(n: Node) -> Array[Node]:
	var out: Array[Node]
	var current = n
	while current:
		out.append(current)
		current = current.get_parent()
	out.reverse()
	return out

# --- random ---

var rng = RandomNumberGenerator.new()
func triangular_distribution(lower: float = -1.0, upper: float = 1.0) -> float:
	return rng.randf_range(upper, lower) + rng.randf_range(upper, lower)

func percent_chance(i):
	return rng.randf() * 100 < i

func cointoss() -> bool:
	return randf() < 0.5

func randf_exp():
	return rng.randf() ** 2

func pick_random_exp(a: Array):
	## each successive element is less likely to be picked
	return a[ int((randf_exp()) * a.size()) ]

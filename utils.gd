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

# --- pools ---

class PoolMemberAttributes:
	var _owner_restore_process_mode: Node.ProcessMode
	var owner: Node:
		set(n):
			_owner_restore_process_mode = n.process_mode
			owner = n

	var active = false:
		set(b):
			active = b
			if "visible" in owner:
				owner.visible = b
			if b:
				owner.process_mode = _owner_restore_process_mode
			else:
				_owner_restore_process_mode = owner.process_mode
				owner.process_mode = Node.PROCESS_MODE_DISABLED

	func _init(_owner: Node, default_active = true):
		owner = _owner
		active = default_active

class Pool:
	var store = []
	var counter = 0:
		set(i):
			while i >= store.size():
				i -= store.size()
			counter = i

	func add(n: Node):
		if "pma" in n and n.pma is PoolMemberAttributes:
			n.pma.active = false
		else:
			push_warning("Warning, no PoolMemberAttributes in node: %s, active and inactive state must by managed manually" % n)
		store.append(n)
	
	func _init(scn: PackedScene, count: int = 2, parent: Node = null):
		for i in range(count):
			var n = scn.instantiate()
			add(n)
			if parent:
				parent.add_child.call_deferred(n)


	func next() -> Node:
		var n = store[counter]
		if n.pma.active:
			push_warning("Warning: pool member %s is still active")
		n.pma.active = true
		counter += 1
		return n

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

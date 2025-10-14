extends Behaviour
class_name Bomber

@export var interval = 10
@export var random_offset = true
@export var require_clear_shot = false
@export var override_shoota: NodePath

var bomb_accum: Dictionary #Behaviours are static so we need to store state in a dictionary
func _initialize(u: Unit):
	bomb_accum[u] = randf_range(0, interval) if random_offset else 0.0

func get_shoota(u: Unit) -> Shoota:
	if override_shoota:
		var shoota = u.get_node(override_shoota)
		if shoota is Shoota:
			return shoota
	for c in u.get_children():
		if c is Shoota:
			return c
	print("Warning: Bomber could not find Shoota on %s" % u)
	return null

func shot_blocked_by_friendly(shoota: Shoota, u: Unit) -> bool:
	if not require_clear_shot:
		return false
	var pq = PhysicsRayQueryParameters2D.new()
	pq.from = shoota.global_position
	pq.to = pq.from + Vector2.DOWN * 200
	pq.collision_mask = u.collision_layer
	var result =  get_physics(u).intersect_ray(pq)
	if result:
		return true
	return false

func _process(u: Unit, delta):
	if u not in bomb_accum:
		print("%s not set up for %s" % [u, self])
		return
	bomb_accum[u] += delta
	while bomb_accum[u] > interval:
		var shoota = get_shoota(u)
		if not shoota:
			return
		if shot_blocked_by_friendly(shoota, u):
			return
		bomb_accum[u] -= interval
		shoota.shoot(Vector2.DOWN)

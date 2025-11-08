extends Unit

@export var max_range = 100
@export_range(0.001, 20, 0.1, "suffix:Hz") var hitrate = 1.0 #NOTE: limited by physics tick rate

var line: Line2D
var pq: PhysicsRayQueryParameters2D
var timer: SceneTreeTimer
func _ready():
	super()
	pq = PhysicsRayQueryParameters2D.new()
	line = $Line2D
	#line.texture = get_sprite().texture
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)

func _physics_process(delta: float) -> void:
	super(delta)
	pq.from = global_position
	var endpoint = direction.normalized() * max_range
	pq.to = pq.from + endpoint
	pq.collision_mask = collision_mask
	var result = get_world_2d().direct_space_state.intersect_ray(pq)
	if result:
		endpoint = result.position - global_position
		if not (timer and timer.time_left):
			handle_collision(result.collider)
			timer = get_tree().create_timer(1.0/hitrate)
	line.set_point_position(1, endpoint / global_scale)

func _get_configuration_warnings():
	var out = super()
	if not (has_node("Line2D") and $Line2D is Line2D):
		out.append("no Line2D")
	return out

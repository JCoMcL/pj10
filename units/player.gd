extends Unit

@export var acceleration = 6
@export var speed = 240
@export var auto_ground = true

func _physics_process(delta):
	super(delta)
	velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
	if move_and_collide(velocity * delta):
		velocity = Vector2.ZERO

func _input(ev: InputEvent):
	if ev.is_action_pressed("fire") or ev.is_action_pressed("up"):
		$Shoota.shoot(Vector2.UP)

func _ready():
	if auto_ground and can_process():
		move_and_collide(Vector2.DOWN * 1000)

var frame_accum = 0.0
func _process(delta):
	direction.x = Input.get_axis("left", "right")
	var atlas = $Sprite2D.texture as HandyAtlas
	if direction.x == 0:
		atlas.set_xy(0,0)
	else:
		if is_zero_approx(velocity.x):
			atlas.set_xy(1,0)
		else:
			const WALK_FRAME_START = 2
			const WALK_FRAMES = 4
			const frame_threshold = 30

			# make sure w are on one of the walk frames
			atlas.cycle_x(0, WALK_FRAME_START, WALK_FRAME_START + WALK_FRAMES -1)

			frame_accum += delta * abs(velocity.x)
			if frame_accum > frame_threshold:
				frame_accum -= frame_threshold
				atlas.cycle_x(1, WALK_FRAME_START, WALK_FRAME_START + WALK_FRAMES -1)
		$Sprite2D.flip_h = (direction.x < 0)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if not has_node("Shoota"):
		warnings.append("Missing child node 'Shoota' (Shoota).")
	else:
		var s = get_node("Shoota")
		# Type check best-effort: ensure it has method 'shoot'
		if not s.has_method("shoot"):
			warnings.append("'Shoota' must expose a 'shoot(direction, parent?)' method.")

	if not has_node("Sprite2D"):
		warnings.append("Missing child node 'Sprite2D' (Sprite2D).")
	else:
		var spr = get_node("Sprite2D")
		if not spr is Sprite2D:
			warnings.append("'Sprite2D' must be a Sprite2D node.")
		else:
			var tex = spr.texture
			if tex == null:
				warnings.append("'Sprite2D' has no texture set; expected HandyAtlas texture.")
			elif typeof(tex) != TYPE_OBJECT or not (tex is HandyAtlas):
				warnings.append("'Sprite2D.texture' should be a HandyAtlas for animations.")

	return warnings

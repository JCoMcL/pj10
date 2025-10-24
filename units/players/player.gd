extends Unit
class_name Player

@export var acceleration = 6
@export var speed = 240
@export var auto_ground = true

func _physics_process(delta):
	super(delta)
	velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
	velocity += get_gravity()
	move_and_slide()

var input_tracker = InputTracker.new()
func _unhandled_input(ev: InputEvent):
	if ev.is_action_pressed("fire") or ev.is_action_pressed("up"):
		$Shoota.shoot(Vector2.UP)
	else:
		input_tracker._input(ev)

var invulnerable = true
func grace_window(seconds=2):
	invulnerable = true
	await Utils.delay(seconds)
	invulnerable = false

func _hit(damage:int=0):
	if not invulnerable:
		super()

func wakeup():
	grace_window()
	super()
	if auto_ground:
		move_and_collide(Vector2.DOWN * 1000)

func _ready():
	if can_process():
		var game = Game.get_game(self)
		if game:
			Game.get_game(self).set_active_player(self)

func _expire():
	super()
	velocity = Vector2(
		500 * (1 if get_sprite(self).flip_h else -1),
		-200
	)

var flash_accum = 0.0
var frame_accum = 0.0
func _process(delta):
	var sprite = get_sprite(self)
	var atlas = sprite.texture as HandyAtlas

	if invulnerable:
		flash_accum += delta
		while flash_accum > 0.1:
			flash_accum -= 0.15
			sprite.visible = !sprite.visible
	else:
		sprite.visible = true

	if alive:
		direction.x = input_tracker.movement_input.x
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
			get_sprite(self).flip_h = (direction.x < 0)
	else:
		atlas.set_xy(6,0)
		direction = Vector2.ZERO
		if abs(velocity.x) < 50 and is_on_floor():
			atlas.set_xy(7,0)
			process_mode = Node.PROCESS_MODE_DISABLED

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if not has_node("Shoota"):
		warnings.append("Missing child node 'Shoota' (Shoota).")
	else:
		var s = get_node("Shoota")
		# Type check best-effort: ensure it has method 'shoot'
		if not s.has_method("shoot"):
			warnings.append("'Shoota' must expose a 'shoot(direction, parent?)' method.")

	return warnings

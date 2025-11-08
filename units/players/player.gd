extends Unit
class_name Player

@export var acceleration = 1800
@export var speed = 240
@export var auto_ground = true
@export var death_sfx: StringName = "beyum"

@export var bomb_cooldown = 0.0
@export var bomb_count = 1 # not implemented
@export var bomb_icon = BombIndicator.Icons.STAR

var shoota: Shoota
var bomba: Shoota
var bomb_countdown: float

func _physics_process(delta):
	super(delta)
	var _acceleration = acceleration if alive else 2400 if is_on_floor() else 800
	velocity.x = move_toward(velocity.x, direction.x * speed * shoota.get_speed_modifier(delta), _acceleration * delta)
	velocity += get_gravity() * delta
	move_and_slide()

var input_tracker = InputTracker.new()
func _unhandled_input(ev: InputEvent):
	if not alive:
		return
	input_tracker._input(ev)
	if ev.is_action_pressed("fire") or ev.is_action_pressed("up"):
		shoota.shoot(Vector2.UP)
	elif ev.is_action_pressed("bomb"):
		bomb()
	elif ev.is_action_pressed("commit_self_die"):
		_hit()

var invulnerable = false
func grace_window(seconds=2):
	var sprite = get_sprite()
	invulnerable = true
	sprite.strobe_rate = 8
	sprite.reset()
	await Utils.delay(seconds)
	invulnerable = false
	sprite.strobe_rate = 0
	sprite.reset()
	sprite.visible = true

func _hit(damage:int=0) -> int:
	if not invulnerable:
		return super()
	return 0

func wakeup():
	grace_window()
	super()
	reset_bomb_cooldown()
	if auto_ground:
		move_and_collide(Vector2.DOWN * 1000)

func claim_points(points: int):
	super(points)
	var game = Game.get_game(self)
	if game:
		game.add_score(points)

func _ready():
	super()
	shoota = $Shoota
	for c in get_children():
		if c is Shoota:
			c.points_claimed.connect(claim_points)
			if c.name == "Bomb":
				bomba = c
	if can_process():
		var game = Game.get_game(self)
		if game:
			Game.get_game(self).set_active_player(self)

func reset_bomb_cooldown():
	bomb_countdown = bomb_cooldown

var active_bomb: Node
func bomb() -> bool:
	if bomb_countdown > 0:
		return false
	if has_node("Bomb") and $Bomb is Shoota:
		active_bomb = await $Bomb.shoot()
	reset_bomb_cooldown()
	return true

func _expire():
	super()
	velocity = Vector2(
		600 * (1 if get_sprite().flip_h else -1),
		-200
	)
	play_sfx(death_sfx)

var frame_accum = 0
func _process(delta):
	var sprite = get_sprite()
	var atlas = sprite.texture as HandyAtlas

	shoota.autoshoot=input_tracker.firing and alive
	if alive:
		bomb_countdown = max(0, bomb_countdown - delta)
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

				# make sure we are on one of the walk frames
				atlas.cycle_x(0, WALK_FRAME_START, WALK_FRAME_START + WALK_FRAMES -1)

				frame_accum += delta * abs(velocity.x)
				if frame_accum > frame_threshold:
					frame_accum -= frame_threshold
					atlas.cycle_x(1, WALK_FRAME_START, WALK_FRAME_START + WALK_FRAMES -1)
			get_sprite().flip_h = (direction.x < 0)
	else:
		atlas.set_xy(6,0)
		direction = Vector2.ZERO
		if abs(velocity.x) < 50 and is_on_floor():
			play_sfx("crunch")
			atlas.set_xy(7,0)
			process_mode = Node.PROCESS_MODE_DISABLED

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = super()
	if not has_node("Shoota") or $Shoota is not Shoota:
		warnings.append("no Shoota")

	return warnings

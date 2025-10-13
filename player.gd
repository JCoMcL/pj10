extends Unit

var direction: float

@export var acceleration = 6
@export var speed = 240

@onready var bullet_pool = Pool.new(preload("res://bullet.tscn"), 3, Pool.PASS, true, false)

func _physics_process(delta):
	super(delta)
	velocity.x = lerp(velocity.x, direction * speed, acceleration * delta)
	if move_and_collide(velocity * delta):
		velocity = Vector2.ZERO

func shoot():
	var bullet = await bullet_pool.next(get_parent())
	if bullet:
		bullet.global_position = global_position

func _input(ev: InputEvent):
	if ev.is_action_pressed("fire") or ev.is_action_pressed("up"):
		shoot()

func _ready():
	move_and_collide(Vector2.DOWN * 1000)

var frame_accum = 0.0
func _process(delta):
	direction = Input.get_axis("left", "right")
	var atlas = $Sprite2D.texture as HandyAtlas
	if direction == 0:
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
		$Sprite2D.flip_h = (direction < 0)

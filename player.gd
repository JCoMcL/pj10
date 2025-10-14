extends Unit

@export var acceleration = 6
@export var speed = 240

func _physics_process(delta):
	super(delta)
	velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
	if move_and_collide(velocity * delta):
		velocity = Vector2.ZERO

func _input(ev: InputEvent):
	if ev.is_action_pressed("fire") or ev.is_action_pressed("up"):
		$Shoota.shoot(Vector2.UP)

func _ready():
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

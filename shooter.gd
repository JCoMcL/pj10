extends CharacterBody2D

var direction: float
func _process(delta):
	direction = Input.get_axis("left", "right")

@export var acceleration = 6
@export var speed = 240

@onready var bullet_pool = Pool.new(preload("res://bullet.tscn"), 3, Pool.PASS, false)

func _physics_process(delta):
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

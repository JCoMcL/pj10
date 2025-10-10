extends CharacterBody2D

var direction: float
func _process(delta):
	direction = Input.get_axis("left", "right")

@export var acceleration = 6
@export var speed = 240

@onready var bullet_pool = Utils.Pool.new(preload("res://bullet.tscn"), 8, get_parent())

func _physics_process(delta):
	velocity.x = lerp(velocity.x, direction * speed, acceleration * delta)
	if move_and_collide(velocity * delta):
		velocity = Vector2.ZERO

func shoot():
	var bullet = bullet_pool.next()
	bullet.position = position

func _input(ev: InputEvent):
	if ev.is_action_pressed("fire") or ev.is_action_pressed("up"):
		shoot()

func _ready():
	move_and_collide(Vector2.DOWN * 1000)

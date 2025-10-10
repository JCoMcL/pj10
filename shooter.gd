extends CharacterBody2D

var direction: float
func _process(delta):
	direction = Input.get_axis("ui_left", "ui_right")

@export var acceleration = 6
@export var speed = 8

@onready var bullet_pool = Utils.Pool.new(preload("res://bullet.tscn"), 8, get_parent())

func _physics_process(delta):
	velocity.x = lerp(velocity.x, direction * speed, acceleration * delta)
	if move_and_collide(velocity):
		velocity = Vector2.ZERO

func shoot():
	var bullet = bullet_pool.next()
	bullet.position = position


func _input(ev: InputEvent):
	if ev.is_action_pressed("ui_up"):
		shoot()

func _ready():
	move_and_collide(Vector2.DOWN * 1000)

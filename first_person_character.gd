@tool
extends CharacterBody3D

@export var height = 1.5:
	set(h):
		height = h
		setup_height()
@export var speed = 3
@export var accel = 15

@export var look_sensitivity = 0.005

@onready var head = $Head
@onready var camera = $Head/Camera3D

var target_move: Vector2
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	target_move = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized().rotated(-head.rotation.y)

func _mouse_motion_input(event: InputEventMouseMotion):
	head.rotate_y(event.relative.x * look_sensitivity * -1)
	camera.rotate_x(event.relative.y * look_sensitivity * -1)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_motion_input(event)

func setup_height():
	if not head: #not ready
		return
	head.position.y = height
	$CollisionShape3D.shape.height - height
	$CollisionShape3D.position.y = height/2
	
func _ready() -> void:
	setup_height()
	
func _physics_process(delta: float) -> void:
	var target_move_3 = Vector3(target_move.x, 0, target_move.y)
	velocity = velocity.move_toward(target_move_3 * speed, accel * delta)
	move_and_slide()

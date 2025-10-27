extends CharacterBody3D
class_name FirstPersonCharacter3D

@export var height = 1.5:
	set(h):
		height = h
		setup_height()
@export var speed = 3
@export var accel = 15

@export var look_sensitivity = 0.005

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interactcast = $Head/Camera3D/PlayerInetractcast

var current_game: ArcadeGame
func atttach_game(g: ArcadeGame):
	current_game = g
	$UserInterface.visible = false if g else true
	if not g:
		setup_height()
	else:
		head.global_transform = g.observation_point.global_transform

func _interact(body: Node3D):
	if not current_game and body is ArcadeGame:
		atttach_game(body)

func _on_interactable_focus_change(n: Node3D):
	if current_game:
		atttach_game(null)

func _mouse_motion_input(event: InputEventMouseMotion):
	head.rotate_y(event.relative.x * look_sensitivity * -1)
	camera.rotate_x(event.relative.y * look_sensitivity * -1)

@onready var input_tracker = InputTracker.new()
func _unhandled_input(event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	elif event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_motion_input(event)

	elif current_game:
		current_game.push_input(event)
	else:
		input_tracker._input(event)

func setup_height():
	if not head: #not ready
		return
	head.position = Vector3(0, height, 0)
	$CollisionShape3D.shape.height - height
	$CollisionShape3D.position.y = height/2

func _ready() -> void:
	setup_height()

func _physics_process(delta: float) -> void:
	var target_move = input_tracker.movement_input.rotated(-head.rotation.y).rotated(-rotation.y)
	var target_move_3 = Vector3(target_move.x, 0, target_move.y)
	velocity = velocity.move_toward(target_move_3 * speed, accel * delta)
	move_and_slide()

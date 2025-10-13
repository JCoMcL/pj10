extends CharacterBody2D

@export var speed = 10
var auto_free = false

signal expire()

func _expire():
	expire.emit()
	if auto_free:
			queue_free()

func _physics_process(delta: float) -> void:
	var hit = move_and_collide(Vector2.UP * speed)
	if hit:
		var struck_object = hit.get_collider()
		if struck_object.has_method("_hit"):
			struck_object._hit()
		_expire()

func on_exit_play_area():
	_expire()


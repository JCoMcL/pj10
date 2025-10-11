extends CharacterBody2D

@export var speed = 20
var auto_free = false

var pma = Pool.MemberAttributes.new(self)

signal on_hit()

func _physics_process(delta: float) -> void:
	var hit = move_and_collide(Vector2.UP * speed)
	if hit:
		var struck_object = hit.get_collider()
		if struck_object.has_method("_hit"):
			struck_object._hit()
		pma.active = false

		on_hit.emit()
		if auto_free:
			queue_free()

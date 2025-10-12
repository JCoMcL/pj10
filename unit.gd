@tool
class_name Unit
extends CharacterBody2D

@export var behaviours: Array[Behaviour]
@export var auto_free = true
signal expire

func _hit():
	expire.emit()
	if auto_free:
		queue_free()

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		for b in behaviours:
			b._process(self, delta)

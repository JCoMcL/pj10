@tool
class_name Unit
extends CharacterBody2D

@export var behaviours: Array[Behaviour]
@export var auto_free = true
@export var expire_outside_play_area = false

signal expire

func _expire():
	expire.emit()
	if auto_free:
		queue_free()

func _hit():
	_expire()

func _on_exit_play_area():
	if expire_outside_play_area:
		_expire()

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		for b in behaviours:
			b._process(self, delta)

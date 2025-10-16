extends Node2D
class_name FauxUnit

@export var behaviours: Array[Behaviour]
@export var auto_free = true

signal expire

var alive = true
func _expire():
	if not alive:
		print("Warning: %s: double expire" % self)
		return
	alive = false
	if auto_free:
		queue_free()
	expire.emit()

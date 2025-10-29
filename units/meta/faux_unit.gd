extends Node2D
class_name FauxUnit

@export var behaviours: Array[Behaviour]
@export var auto_free = true

var health: int
var current_health: int

signal expire
signal hit

var alive = true
func _expire():
	if not alive:
		print("Warning: %s: double expire" % self)
		return
	alive = false
	if auto_free:
		queue_free()
	expire.emit()

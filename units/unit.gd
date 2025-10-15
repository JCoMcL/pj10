@tool
class_name Unit
extends CharacterBody2D

@export var behaviours: Array[Behaviour]
@export var auto_free = true
@export var points_worth = 0
@export var expire_outside_play_area = false:
	set(b):
		expire_outside_play_area = b
		if b:
			collision_layer |= Utils.layers["AreaBounded"]
		else:
			collision_layer &= ~Utils.layers["AreaBounded"]

static func get_sprite(instance: Unit) -> Sprite2D:
	for c in instance.get_children():
		if c is Sprite2D:
			return c
	return null

var direction: Vector2

signal expire

var alive = true
func _expire():
	if not alive:
		print("Warning: %s: double expire" % self)
		return
	alive = false
	if points_worth:
		Game.get_game(self).add_score(points_worth)
	if auto_free:
		queue_free()
	expire.emit()

func _hit():
	_expire()

func _on_exit_play_area():
	assert(expire_outside_play_area)
	if alive:
		_expire()

func _enter_tree() -> void:
	alive = true

func handle_collision(c: Node2D):
	for b in behaviours:
		b._handle_collision(c, self)

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		for b in behaviours:
			b._process(self, delta)

func _ready():
	expire_outside_play_area = expire_outside_play_area
	if not Engine.is_editor_hint():
		for b in behaviours:
			b._initialize(self)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray
	if not get_sprite(self):
		warnings.append("no Sprite2D")
	return warnings
